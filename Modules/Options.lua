local addonName, addon = ...
local Options = addon:NewModule("Options", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetLists = AceGUIWidgetLSMlists
--------------------------------------------------------------------------------------------------------

local SPAM_LEVEL_1 = 0.02
local SPAM_LEVEL_2 = 0.3
local SPAM_LEVEL_3 = 1
local SPAM_LEVEL_4 = 2
local SPAM_LEVEL_5 = 3.3

addon.spammercolor = {
	{SPAM_LEVEL_5, "|cfff51000"},
	{SPAM_LEVEL_4, "|cffff9900"},
	{SPAM_LEVEL_3, "|cffffea00"},
	{SPAM_LEVEL_2, "|cff00aaff"},
	{SPAM_LEVEL_1, "|cff00ff00"},
	{0, "|cffffffff"},
}

--  Options
Options.defaults = {
	global = {
		-- message filtering on or off
		message_filter_switch = true,
		-- hook engine on/off
		message_hook_switch = true,
		-- analysis run params
		analysis = {
			interval = 600,
		},
		-- compact db
		compactdb = {
			interval = 900,
		},
		-- current set threshold of spam filtering
		-- 0: off, 1: miniman
		filtering_level = "4",
		-- level to score mapping: level, 
		level_score_map = {
			--["0"] = 0,				-- off
			["1"] = SPAM_LEVEL_1,		-- Minimum
			["2"] = SPAM_LEVEL_2,		-- Talkative
			["3"] = SPAM_LEVEL_3,		-- Annoying
			["4"] = SPAM_LEVEL_4,		-- Spammer
			["5"] = SPAM_LEVEL_5,		-- Bot
		},
		-- beyond this trigger learning (1 hour)
		hourly_learning_threshold = 10,
		-- beyond this trigger learning after hourly check false
		daily_learning_threshold = 30,
		-- low than this trigger remove from leanring (in 5 days)
		penalty_threshold = 20,
		-- messages received time diff lower than this consider as periodcally (mostly spams)
		deviation_threshold = 0.25,
		-- learning list
		plist = {},
		-- pre-learning list
		prelearning = {},
		-- font size
		fontsize = 12.8,
		-- ui window save status
		ui = {
			height = 50,
			top = 417,
			left = 7,
			width = 80,
		},
	},
}

local top500list = ""

function Options:Load()
    local keywords_enUS = {
    };

    local keywords_zhCN = {
    };

    -- loading default keywords based on locale
	if( addon.db.global.keywords == nil ) then
		if( GetLocale() == "zhCN" ) then
			addon.db.global.keywords = keywords_zhCN
		else 
			addon.db.global.keywords = keywords_enUS
		end
	end

	addon.db.global.creator_addon_version = addon.db.global.creator_addon_version or addon.METADATA.VERSION

	addon.db.global.ui_switch_on = addon.db.global.ui_switch_on or true
end

function Options:SaveSession()
	if addon.AcamarGUI.display ~= nil and addon.AcamarGUI.display:IsShown() then
		addon.db.global.ui_switch_on = true
	else
		addon.db.global.ui_switch_on = false
	end
end

-- Set filtering flag on/off
function addon:ToggleFiltering()
    addon.db.global.message_filter_switch = not addon.db.global.message_filter_switch
	--addon:log("Filtering is " .. tostring(addon.db.global.message_filter_switch))

	if addon.db.global.message_filter_switch then
		addon:log(L["Chat messages filtering started."])
	else
		addon:log(L["Chat messages filtering stopped, but learning engine still running."])
	end

    -- update UI to reflect current filter status
    addon.AcamarGUI:UpdateAddonUIStatus(addon.db.global.message_filter_switch)
end

-- Turn on/off engine
function addon:HookSwitch()
	if addon.db.global.message_hook_switch then
		if not addon.AcamarMessage.engine_running then
			addon:log(L["Turn on learning engine..."])
			addon.AcamarMessage:HookOn()
		end
	else
		if addon.AcamarMessage.engine_running then
			addon.AcamarMessage:HookOff()
			addon:log(L["Turn off learning engine..."])
		end
	end
end

----------- options functions
function WhisperListToSelf(info) 
	addon:log("Printing banned list: Player Name [spam score]") 

	SendChatMessage(L["Currently banned players:"], "WHISPER", nil, UnitName("player"))
    for k,v in pairs(addon.db.global.pfeatures) do 
		-- exceed blacklist threshold
		if ( v.score >= addon.FilterProcessor.filter_score ) then
			SendChatMessage(v.name .. " [" .. v.score .. "]" , "WHISPER", nil, UnitName("player"))
		end
    end
end

-- get sorted keys
local function keysSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)

    return keys
end

function PrintBannedList(info)
	local bannedlist = {}

	for k, v in pairs(addon.db.global.pfeatures) do
		if ( v.score >= addon.FilterProcessor.filter_score ) then
			tinsert(bannedlist, {name=v.name, score=v.score})
		end
    end


	local sort_field = "score"
	function tcompare(a, b)
		return a[sort_field]>b[sort_field]
	end

	local sortedKeys = keysSortedByValue(bannedlist, tcompare)

	addon:log(L["Top 500 spammers with spam score greater than "] .. addon.FilterProcessor.filter_score) 
	local counter=0
	for _, key in ipairs(sortedKeys) do
		spamcolor = "|cffffffff"
		for i=1, #addon.spammercolor do
			if bannedlist[key].score >= addon.spammercolor[i][1] then
				spamcolor = addon.spammercolor[i][2]
				break
			end
		end

		addon:log(bannedlist[key].name .. " [" .. spamcolor .. bannedlist[key].score .. "|r]")
		counter = counter + 1
		if counter>=500 then
			break
		end
    end
	addon:log(L["Total players in banned list: "] .. counter) 
end

function GetBannedList(max)
	-- addon:log("GetBannedList")

	local bannedlist = {}
	local list = ""

	local prec = 0
	for k, v in pairs(addon.db.global.pfeatures) do
		if ( v.score >= 0 ) then
			tinsert(bannedlist, {name=v.name, score=v.score})
			prec = prec + 1
		end
    end

    if prec == 0 then
    	return L["Learning in progress ..."]
    end

	local sort_field = "score"
	function tcompare(a, b)
		return a[sort_field]>b[sort_field]
	end

	local sortedKeys = keysSortedByValue(bannedlist, tcompare)

	list = L["Top players with spam score. Max "] .. max .. "\n\n"
	list = list .. L["The list changes along with the learning progress."] .. "\n\n"

	local counter=0
	for _, key in ipairs(sortedKeys) do
		spamcolor = "|cffffffff"
		for i=1, #addon.spammercolor do
			if bannedlist[key].score >= addon.spammercolor[i][1] then
				spamcolor = addon.spammercolor[i][2]
				break
			end
		end

		list = list .. bannedlist[key].name .. " [" .. spamcolor .. bannedlist[key].score .. "|r]" .. "\n"
		counter = counter + 1
		if counter>=500 then
			break
		end
    end
	list = list .. "\n" .. L["Total players in the list: "] .. counter

	return list
end

function GetBannedTable(max)
	local bannedlist = {}
	local list = {}

	local prec = 0
	for k, v in pairs(addon.db.global.pfeatures) do
		if ( v.score >= 0 ) then
			tinsert(bannedlist, {name=v.name, score=v.score})
			prec = prec + 1
		end
    end

    if prec == 0 then
    	return {"0", L["Learning in progress ..."]}
    end

	local sort_field = "score"
	function tcompare(a, b)
		return a[sort_field]>b[sort_field]
	end

	local sortedKeys = keysSortedByValue(bannedlist, tcompare)

	local counter=1
	for _, key in ipairs(sortedKeys) do
		spamcolor = "|cffffffff"
		for i=1, #addon.spammercolor do
			if bannedlist[key].score >= addon.spammercolor[i][1] then
				spamcolor = addon.spammercolor[i][2]
				break
			end
		end

		local idx = string.format("%08d", counter)

		list[idx] = bannedlist[key].name .. " [" .. spamcolor .. bannedlist[key].score .. "|r]" .. "\n"
		counter = counter + 1
		if counter>500 then
			break
		end
    end
	list["end"] = "|cff00cccc" .. L["Total players in the list: "] .. counter

	return list
end

function ResetAcamarDB(info)
	addon:log(L["Resetting DB and learning enging..."])

	addon.resetting_flag = true

	-- reset plist
	addon.db.global.plist = {}

	-- reset prelearning
	addon.db.global.prelearning = {}

	-- reset pfeatures
	addon.db.global.pfeatures = {}

	addon.resetting_flag = false
end

function Options.GetOptions(uiType, uiName, appName)
	if appName == addonName then
		--top500list = GetBannedList(500)

		local options  = {
			type = "group",
			name = addon.METADATA.NAME .. " (" .. addon.METADATA.VERSION .. ")",
			get = function(info)
					return addon.db.global[info[#info]] or ""
				end,
			set = function(info, value)
					addon.db.global[info[#info]] = value
					--[[
					addon.Data:UpdateSession()
					if addon.AcamarGUI.display then
						addon.GUI.container:Reload()
					end
					]]
				end,
			args = {
				main_settings = {
					type = "group",
					childGroups = "tab",
					name = L["Engine Settings"],
					order = 1.0,
					args = {
						addoninfo = {
							type = "description",
							name = L["ADDON_INFO"],
							descStyle = L["ADDON_INFO"],
							order = 0.1,
						},

						header01 = {
							type = "header",
							name = "",
							order = 1.01,
						},

						filtering_level = {
							type = "select",
							width = "full",
							name = L["Filtering Level"],
							desc = L["Set messages filtering level"],
							values = { 	
										--["0"] = L["Off"],
										["1"] = L["Most strict level with minimum spam"] .. " [" .. SPAM_LEVEL_1 .. "]",
										["2"] = L["Bots, spammers, annoying senders and talkative players away"] .. " [" .. SPAM_LEVEL_2 .. "]",
										["3"] = L["Block bots, spammers and annoying messages"] .. " [" .. SPAM_LEVEL_3 .. "]",
										["4"] = L["Block bots and spammers"] .. " [" .. SPAM_LEVEL_4 .. "]",
										["5"] = L["Block bots only"] .. " [" .. SPAM_LEVEL_5 .. "]",
									},
							get = function(info)
									return addon.db.global[info[#info]] or ""
								end,
							set = function(info, value)
									addon.db.global[info[#info]] = value
									addon.FilterProcessor:UpdateFilterScore(value)
								end,
							order = 1.1,
						},

						header06 = {
							type = "header",
							name = "",
							order = 2.01,
						},

						authorinfo = {
							type = "description",
							name = L["AUTHOR_INFO"],
							descStyle = L["AUTHOR_INFO"],
							order = 2.1,
						},
					},
				},

				adv_settings = {
					type = "group",
					childGroups = "tab",
					name = L["Advanced Settings"],
					order = 3.0,
					args = {
						message_hook_switch = {
							type = "toggle",
							width = "full",
							name = L["Turn On Engine"],
							desc = L["Turn on messages filtering and learning engine. If turn off, messages will not be filtered."],
							width = "normal",
							set = function(info,val) 
									addon.db.global.message_hook_switch = val 
									addon:HookSwitch()
								end,
		      				get = function(info) 
		      						return addon.db.global.message_hook_switch 
		      					end,
							order = 3.1,
						},

						header03 = {
							type = "header",
							name = "",
							order = 5.01,
						},

						command_cleardb = {
							type = "execute",
							width = "normal",
							name = L["Reset and re-learn"],
							confirm = true,
							desc = L["Reset DB to initial status and begin to re-learn players' behavior."],
							func = function(info) ResetAcamarDB(info) end,
							order = 5.1,
						},
					},
				},

				spamscore_panel = {
					type = "group",
					childGroups = "tab",
					name = L["Spam score"],
					order = 7.0,
					args = {
						top500_list_desc = {
							type = "description",
							name = "|cff00cccc" .. L["Top players with spam score. Max "] .. "500" .. "\n" ..
								L["The list changes along with the learning progress."] .. "|r",
							order = 8.02,
						},
						top500_list_select = {
							type = "multiselect",
							width = "full",
							disabled = true,
							name = "",
							descStyle = L["The list changes along with the learning progress."],
							values = function(info) return GetBannedTable(500) end,
							order = 8.1,
						},								
					},
				},

				about_panel = {
					type = "group",
					childGroups = "tab",
					name = L["About"],
					order = 9.0,
					args = {
						top500_list_desc = {
							type = "description",
							name = L["ABOUT_INFO"],
							order = 9.01,
						},
					},
				},
			},
		}

		return options
	end
end

-- EOF
