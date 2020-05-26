local addonName, addon = ...
local Options = addon:NewModule("Options", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetLists = AceGUIWidgetLSMlists
--------------------------------------------------------------------------------------------------------

--  Options
Options.defaults = {
	global = {
		-- message filtering on or off
		message_filter_switch = true,
		-- hook engine on/off
		message_hook_switch = true,
		-- analysis run params
		analysis = {
			interval = 300,
		},
		-- compact db
		compactdb = {
			interval = 600,
		},
		-- current set threshold of spam filtering
		-- 0: off, 1: miniman
		filtering_level = "4",
		-- level to score mapping: level, 
		level_score_map = {
			--["0"] = 0,			-- off
			["1"] = 0.05,		-- Minimum
			["2"] = 0.2,		-- Talkative
			["3"] = 0.5,		-- Annoying
			["4"] = 1,			-- Spammer
			["5"] = 3,			-- Bot
		},
		-- beyond this trigger learning (1 hour)
		hourly_learning_threshold = 20,
		-- beyond this trigger learning after hourly check false
		daily_learning_threshold = 50,
		-- low than this trigger remove from leanring (in 5 days)
		penalty_threshold = 20,
		-- messages received time diff lower than this consider as periodcally (mostly spams)
		deviation_threshold = 0.25,
		-- score threshold for dynamic blacklist
		blacklist_score_thres = 5,
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
	addon:log("Filtering is " .. tostring(addon.db.global.message_filter_switch))
    -- update UI to reflect current filter status
    addon.AcamarGUI:UpdateAddonUIStatus(addon.db.global.message_filter_switch)
end

-- Turn on/off engine
function addon:HookSwitch()
	if addon.db.global.message_hook_switch then
		if not addon.AcamarMessage.engine_running then
			addon:log("Turn on engine...")
			addon.AcamarMessage:HookOn()
		end
	else
		if addon.AcamarMessage.engine_running then
			addon.AcamarMessage:HookOff()
			addon:log("Turn off engine...")
		end
	end
end

function Options.GetOptions(uiType, uiName, appName)
	if appName == addonName then

		local options = {
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
								["1"] = L["Let me be quiet"],
								["2"] = L["Silent talkative"],
								["3"] = L["Annoying messages away"],
								["4"] = L["Only block spammers"],
								["5"] = L["Only block Bots"],
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

				header02 = {
					type = "header",
					name = "",
					order = 2.01,
				},

				message_hook_switch = {
					type = "toggle",
					width = "normal",
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
					order = 2.1,
				},

				header06 = {
					type = "header",
					name = "",
					order = 6.01,
				},

				authorinfo = {
					type = "description",
					name = L["AUTHOR_INFO"],
					descStyle = L["AUTHOR_INFO"],
					order = 6.1,
				},
			},
		}
		return options
	end
end

-- EOF
