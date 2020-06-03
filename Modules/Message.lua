local addonName, addon = ...
local AcamarMessage, L, AceGUI, private
------------------------------------------------------------------------------
local GetNumFriends, GetFriendInfo
local chatEvents

if(addonName ~= nil) then
    AcamarMessage = addon:NewModule("AcamarMessage", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
    L = LibStub("AceLocale-3.0"):GetLocale(addonName)
    AceGUI = LibStub("AceGUI-3.0")
    private = {}

    GetNumFriends = C_FriendList.GetNumFriends
    GetFriendInfo = C_FriendList.GetFriendInfo

    chatEvents = 
    {
        [addon.MSG_FILTER_CHANNEL_SET_NORMAL] = {
            "CHAT_MSG_CHANNEL",
            "CHAT_MSG_SAY",
            "CHAT_MSG_YELL",
            "CHAT_MSG_EMOTE",
            "CHAT_MSG_WHISPER",
        },
        [addon.MSG_FILTER_CHANNEL_SET_PLUS_PARTY_RAID] = {
            "CHAT_MSG_CHANNEL",
            "CHAT_MSG_SAY",
            "CHAT_MSG_YELL",
            "CHAT_MSG_EMOTE",
            "CHAT_MSG_WHISPER",
            "CHAT_MSG_PARTY",
            "CHAT_MSG_RAID",
        },
        [addon.MSG_FILTER_CHANNEL_SET_PLUS_GUILD] = {
            "CHAT_MSG_CHANNEL",
            "CHAT_MSG_SAY",
            "CHAT_MSG_YELL",
            "CHAT_MSG_EMOTE",
            "CHAT_MSG_WHISPER",
            "CHAT_MSG_GUILD",
        },
        [addon.MSG_FILTER_CHANNEL_SET_PLUS_BOTH] = {
            "CHAT_MSG_CHANNEL",
            "CHAT_MSG_SAY",
            "CHAT_MSG_YELL",
            "CHAT_MSG_EMOTE",
            "CHAT_MSG_WHISPER",
            "CHAT_MSG_GUILD",
            "CHAT_MSG_PARTY",
            "CHAT_MSG_RAID",
        },
    }
else
    addon = {}
    L = {}
    AcamarMessage = {}
end

--local BNGetNumFriendToons = C_BattleNet.GetFriendNumGameAccounts

--local serverName = GetRealmName()

-- debug purpose, should change upon module load status
Acamar_Loaded = true

local REWRITE_PREFIX = L["[RW] "]

local prevLineID = 0
local modifyMsg = nil
local block = nil

--[[
sample data
["testmsgdata"] = {
    ["player_name_only"] = "丽人",
    ["guid"] = "Player-4520-01C34999",
    ["flag"] = "",
    ["message"] = "{方块}{方块}长期无限收<丝绸=0.35g/组><魔纹布=0.80g/组><符文布=0.95g/组><厚皮=1.25g/组><硬甲皮=1.35g/组>{菱形}{菱形}不卡邮箱，扰屏见谅。{方块}{方块}{方块}{方块}",
    ["event"] = "CHAT_MSG_CHANNEL",
    ["chan_id_name"] = "1. 大脚世界频道",
    ["chan_num"] = 1,
    ["from"] = "丽人",
    ["chan_id"] = 0,
    ["line_id"] = 12,
    ["u"] = 0,
    ["lang"] = "",
    ["chan_name"] = "大脚世界频道",
},
]]

local function RewriteMessage(ori)
    if (ori == nil) then
        return nil
    end

    local len = string.len(ori)

    if len<2 then
        return ori
    end

    haslink = find_link(ori)
    -- skip message with item link
    if(haslink) then
        return
    end    

    local mmsg = nil

    if((len>=4) and (len%2==0)) then
        mmsg = find_repeat_pattern_fast(ori)
    end

    -- second stage rewrite currently disabled because of in-consistency
    --[[
    if(mmsg == nil) then
        mmsg = remove_char_repeats_fast(ori)
        -- only keep modify string which can be rewrite to more than half of the length
        if(mmsg ~= nil) then
            if(string.len(mmsg) > len/2) then
                mmsg = nil
            end
        end
    end
    ]]

    return mmsg
end

--- Remove server names from names given as "Character-Servername"
-- @param name The name to remove the dash server part from
local function RemoveServerDash(name)
    local dash = name:find("-");
    if dash then 
        return name:sub(1, dash-1); 
    end
    return name;
end

local function IsFriend(name)
    if not name then
        return
    end

    -- myself
    if name == UnitName("player") then
        return true
    end

    -- guild/party/raid member
    if UnitIsInMyGuild(name) or UnitInRaid(name) or UnitInParty(name) then
        return true
    end

    -- friends
    for i = 1, GetNumFriends() do
        if GetFriendInfo(i) == name then
            return true
        end
    end
    --[[
    local _, numBNFriends = BNGetNumFriends()
    for i = 1, numBNFriends do
        for j = 1, BNGetNumFriendToons(i) do
            local _, toonName = BNGetFriendToonInfo(i, j)
            if toonName == name then
                return true
            end
        end
    end
    ]]
end

local acamarFilter = function(self, event, message, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...)

    msgdata = {
        --self = self,
        event = event,
        message = message,
        from = from,
        lang = lang,
        chan_id_name = chan_id_name,
        player_name_only = player_name_only,
        flag = flag,
        chan_id = chan_id, -- start from 0
        chan_num = chan_num, -- start from 1
        chan_name = chan_name, -- channel name only
        u = u,
        line_id = line_id,
        guid = guid,
        receive_time = time(),
    }    

    -- let some events pass
    if event == "CHAT_MSG_SYSTEM" then  
        if message == ERR_IGNORE_NOT_FOUND then
            return false
        end
        if message == ERR_IGNORE_ALREADY_S then
            return false
        end
        if message == ERR_IGNORE_FULL then
            return false
        end
    end
    
    -- If module not fully loaded, skip filter
    if Acamar_Loaded ~= true then
        return false
    end
    
    -- let npc messages pass    
    if event == "CHAT_MSG_MONSTER_EMOTE" or event == "CHAT_MSG_MONSTER_PARTY" or event == "CHAT_MSG_MONSTER_SAY" or
       event == "CHAT_MSG_MONSTER_WHISPER" or event == "CHAT_MSG_MONSTER_YELL" then
            return false;
    -- let system messages pass
    elseif event == "CHAT_MSG_SYSTEM" then
        return false
    -- bypass GM/dev
    elseif flag == "GM" or flag == "DEV" then
        return false
    -- let notice and invite events pass
    elseif event == "CHAT_MSG_CHANNEL_NOTICE_USER" and message == "INVITE" then
        return false
    elseif (from ~= nil) and (from ~= "") then
        local shortname = RemoveServerDash(from)

        -- bypass friends
        if addon.db.global.bypass_friends and IsFriend(shortname) then
            --addon:log("bypass friend message: [" .. shortname .. "] " .. message)
            return
        end

        -- bypass whitelist
        if addon.db.global.wl[shortname] ~= nil then
            return
        end

        if line_id == prevLineID then
            -- skip
            if modifyMsg and addon.db.global.message_rewrite then
                --addon:log("rewrite 1")
                --modify = RewriteMessage(message)
                return false, modifyMsg, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
            elseif block then
                return true
            else
                --return false, modifyMsg, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
                return false
            end
        else
            -- addon:log(table_to_string({line_id=line_id, prevLineID=prevLineID, player=player}))

            prevLineID, modifyMsg, block = line_id, nil, nil

            block, score = addon.FilterProcessor:OnNewMessage(msgdata)
            -- block the message
            if block then
                return true
            end

            -- Rewrite message if set. Only apply to channel, say, yell
            if( (event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" ) 
                and addon.db.global.message_rewrite ) then
                -- get rewritten message
                remsg = RewriteMessage(message)
                --remsg = "hello"
                if(remsg ~= nil) then
                --if(string.find(message, "G")) then
                    modifyMsg = REWRITE_PREFIX .. remsg
                    -- rewrite message
                    --addon:log("rewrite from : " .. from .. ": " .. message)
                    --addon:log("rewrite to: " .. modifyMsg)
                    return false, modifyMsg, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
                end
            end 

        end
    end

    return false
end

--[[
local acamarFilter_v1 = function(self, event, message, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...)

    msgdata = {
        --self = self,
        event = event,
        message = message,
        from = from,
        lang = lang,
        chan_id_name = chan_id_name,
        player_name_only = player_name_only,
        flag = flag,
        chan_id = chan_id, -- start from 0
        chan_num = chan_num, -- start from 1
        chan_name = chan_name, -- channel name only
        u = u,
        line_id = line_id,
        guid = guid,
        receive_time = time(),
    }    

    --if lastMsg ~= message then    
    --  t = string.gsub(message, "|", "!")
    --  print ("chatMsg evt=" .. (event or "nil") .. " msg=".. (t or "nil") .. " from=" .. (from or "nil"))
    --  lastMsg = message
    --end

    -- let some events pass
    if event == "CHAT_MSG_SYSTEM" then  
        if message == ERR_IGNORE_NOT_FOUND then
            return false
        end
        if message == ERR_IGNORE_ALREADY_S then
            return false
        end
        if message == ERR_IGNORE_FULL then
            return false
        end
    end
    
    -- If module not fully loaded, skip filter
    if Acamar_Loaded ~= true then
        return false
    end
    
    -- let npc messages pass    
    if event == "CHAT_MSG_MONSTER_EMOTE" or event == "CHAT_MSG_MONSTER_PARTY" or event == "CHAT_MSG_MONSTER_SAY" or
       event == "CHAT_MSG_MONSTER_WHISPER" or event == "CHAT_MSG_MONSTER_YELL" then
            return false;
    -- let system messages pass
    elseif event == "CHAT_MSG_SYSTEM" then
        return false
    -- let notice and invite events pass
    elseif event == "CHAT_MSG_CHANNEL_NOTICE_USER" and message == "INVITE" then
        return false
    elseif (from ~= nil) and (from ~= "") then
        if line_id == prevLineID then
            -- skip
            if false and addon.db.global.message_rewrite then
                addon:log("rewrite 1")
                modify = RewriteMessage(message)
                return false, modify, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
            elseif block then
                return true
            else
                return
            end
        else
            -- addon:log(table_to_string({line_id=line_id, prevLineID=prevLineID, player=player}))

            prevLineID, modifyMsg, block = line_id, nil, nil

            --scan customized channels like bigfoot
            local trimmedPlayer = Ambiguate(from, "none")
            if event == "CHAT_MSG_CHANNEL" and (chan_id == 0 or type(chan_id) ~= "number") then 
                -- Forward message to processor to study the behavior of sender and classfy spam level of message and sender
                block, score = addon.FilterProcessor:OnNewMessage(msgdata)
                -- block the message
                if block then
                    return true
                end

                if(false and addon.db.global.message_rewrite == true) then
                    modify = RewriteMessage(message)
                    --if(modify ~= nil) then
                    if(string.find(message, "G")) then
                        -- rewrite message
                        addon:log("rewrite 2 from : ".. message)
                        addon:log("rewrite 2 to: ".. modify)
                        return false, modify, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
                    end
                end

                return 
            end 

            --Don't filter ourself/friends/guild
            if UnitIsInMyGuild(trimmedPlayer) then 
                return 
            end 
            
            -- Forward message to processor to study the behavior of sender and classfy spam level of message and sender
            block, score = addon.FilterProcessor:OnNewMessage(msgdata)
            -- block the message
            if block then
                return true
            end

            if(addon.db.global.message_rewrite == true) then
                -- do modify message
                modify = RewriteMessage(message)
                if(modify == nil) then
                    -- return without modify
                    return false
                else
                    -- rewrite message
                    addon:log("rewrite 3 from: " .. modify)
                    addon:log("rewrite 3 to: " .. modify)
                    return false, modify, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
                end
            end

        end
    end         
    
    return false
end

--main filtering function

local acamarFilter_v2 = function(self, event, message, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...)

    msgdata = {
        --self = self,
        event = event,
        message = message,
        from = from,
        lang = lang,
        chan_id_name = chan_id_name,
        player_name_only = player_name_only,
        flag = flag,
        chan_id = chan_id, -- start from 0
        chan_num = chan_num, -- start from 1
        chan_name = chan_name, -- channel name only
        u = u,
        line_id = line_id,
        guid = guid,
        receive_time = time(),
    }    

    -- If module not fully loaded, skip filter
    if Acamar_Loaded ~= true then
        return false
    end

     -- let npc messages pass    
    if event == "CHAT_MSG_MONSTER_EMOTE" or event == "CHAT_MSG_MONSTER_PARTY" or event == "CHAT_MSG_MONSTER_SAY" or
       event == "CHAT_MSG_MONSTER_WHISPER" or event == "CHAT_MSG_MONSTER_YELL" then
            return false;
    -- let system messages pass
    elseif event == "CHAT_MSG_SYSTEM" then
        return false
    -- let notice and invite events pass
    elseif event == "CHAT_MSG_CHANNEL_NOTICE_USER" and message == "INVITE" then
        return false
    elseif lineId == prevLineID then
        if modifyMsg then
            return false, modifyMsg, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
        elseif block then
            return true
        else
            return
        end
    else
        prevLineID, modifyMsg, block = line_id, nil, nil

        -- customized channels like bigboot
        if event == "CHAT_MSG_CHANNEL" and (chan_id == 0 or type(chan_id) ~= "number") then 
            return 
        end 

        if UnitIsInMyGuild(from) then 
            return 
        end --Don't filter ourself/friends/guild

        block, score = addon.FilterProcessor:OnNewMessage(msgdata)
        -- block the message
        if block then
            return true
        end

        if(addon.db.global.message_rewrite == true) then
            remsg = RewriteMessage(message)
            if(remsg ~= nil) then
            --if(string.find(message, "G")) then
                modifyMsg = msg
                -- rewrite message
                addon:log("rewrite 2 from : ".. message)
                addon:log("rewrite 2 to: ".. modifyMsg)
                return false, modifyMsg, from, lang, chan_id_name, player_name_only, flag, chan_id, chan_num, chan_name, u, line_id, guid, ...
            end
        end        

    end
end
]]


function AcamarMessage:OnInitialize()
    --addon:Printf("AcamarMessage:OnInitialize()")
    self.engine_running = false
end
--[[
        "CHAT_MSG_ACHIEVEMENT",
        "CHAT_MSG_BATTLEGROUND",
        "CHAT_MSG_BATTLEGROUND_LEADER",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_CHANNEL_JOIN",
        "CHAT_MSG_CHANNEL_LEAVE",
        "CHAT_MSG_CHANNEL_NOTICE_USER",
        "CHAT_MSG_EMOTE",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_GUILD_ACHIEVEMENT",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_MONSTER_EMOTE",
        "CHAT_MSG_MONSTER_PARTY",
        "CHAT_MSG_MONSTER_SAY",
        "CHAT_MSG_MONSTER_WHISPER",
        "CHAT_MSG_MONSTER_YELL",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_SAY",
        "CHAT_MSG_SYSTEM",
        "CHAT_MSG_TEXT_EMOTE",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_YELL",
]]

function AcamarMessage:HookOn( channels )
    addon:log(L["Message filtering running ..."])
    --addon:log("Hooking messages " .. channels)

    for key, value in pairs (chatEvents[channels]) do
        ChatFrame_AddMessageEventFilter(value, acamarFilter)
    end
    self.engine_running = true
end

function AcamarMessage:HookOff( channels )
    addon:log(L["Message filtering stopped."])
    --addon:log("Unhooking messages " .. channels)

    for key, value in pairs (chatEvents[channels]) do
        ChatFrame_RemoveMessageEventFilter(value, acamarFilter)
    end
    self.engine_running = false
end

-----------
-- misc functions
-- Convert a lua table into a lua syntactically correct string
function table_to_string(tbl)
    if table == nil then
        return "{result=nil}"
    end

    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..tostring(v).."\""
        end
        result = result..", "
    end
    -- Remove leading commas from the result
    if result ~= "{" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

function serialize(obj)
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{"  
        for k, v in pairs(obj) do  
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ", "  
        end  
        local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
            for k, v in pairs(metatable.__index) do  
                lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ", "  
            end  
        end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end

function table2string(tablevalue)
    local stringtable = serialize(tablevalue)
    return stringtable
end

function copy_table(settings)
    local copy = {};
    for k, v in pairs(settings) do
        if ( type(v) == "table" ) then
            copy[k] = CopyTable(v);
        else
            copy[k] = v;
        end
    end
    return copy;
end
-----------
-- unused
--[[
local filterBackup = function(self, event, msg, player, lang, chan, tar, flag, chanid, chanNum, chanName, u, lineId, guid)
    if lineId == prevLineID then
        if modify then
            return false, modify, player, lang, chan, tar, flag, chanid, chanNum, chanName, u, lineId, guid
        elseif result then
            return true
        else
            return
        end
    else
        prevLineID, modify, result = lineId, nil, nil

        --Only scan official custom channels (gen/trade)
        local trimmedPlayer = Ambiguate(player, "none")
        if event == "CHAT_MSG_CHANNEL" and (chanid == 0 or type(chanid) ~= "number") then 
            return 
        end 

        --Don't filter ourself/friends/guild
        if UnitIsInMyGuild(trimmedPlayer) then 
            return 
        end 
        
        local lowMsg = msg:lower() --lower all text

        for i = 1, #BADBOY_CCLEANER do --scan DB for matches
            if lowMsg:find(BADBOY_CCLEANER[i], nil, true) then
                if BadBoyLog then BadBoyLog("CCleaner", event, trimmedPlayer, msg) end
                result = true
                return true 
                --found a trigger, filter
            end
        end

        if BADBOY_NOICONS and msg:find("{", nil, true) then
            local found = 0
            for i = 1, #knownIcons do
                msg, found = gsub(msg, knownIcons[i], "")
                if found > 0 then modify = msg end 
                --Set to true if we remove a raid icon from this message
            end

            --only modify message if we removed an icon
            if modify then 
                return false, modify, player, lang, chan, tar, flag, chanid, chanNum, chanName, u, lineId, guid
            end
        end
    end
end
]]