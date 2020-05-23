local addonName, addon = ...
local Options = addon:NewModule("Options", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetLists = AceGUIWidgetLSMlists
--------------------------------------------------------------------------------------------------------

--  Options
Options.defaults = {
	global = {
		globalswitch = true,
		score_threshold = 50,
		hourly_threshold = 2000,
		penalty_threshold = 500,
		fontsize = 12.8,
		ui = {
			height = 50,
			top = 417,
			left = 7,
			width = 88,
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

	-- testing data
	addon.db.profile.testmsgdata = addon.db.profile.testmsgdata or {}

	--addon:Printf("globalswitch=" .. tostring(addon.db.global.globalswitch))
end

function Options:SaveSession()
	if addon.AcamarGUI.display ~= nil and addon.AcamarGUI.display:IsShown() then
		addon.db.global.ui_switch_on = true
	else
		addon.db.global.ui_switch_on = false
	end
end

--- Toggle search on/off
function addon:ToggleAddon()
    addon.db.global.globalswitch = not addon.db.global.globalswitch
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

				max_topic_live_secs = {
					type = "range",
					width = "double",
					min = 10,
					max = 600,
					step = 1,
					softMin = 10,
					softMax = 600,
					name = L["Message alive time"],
					desc = L["How long will message be removed from event (default to 120 seconds)?"],
					width = "normal",
					order = 1.1,
				},

				header02 = {
					type = "header",
					name = "",
					order = 2.01,
				},

				fontsize = {
					type = "range",
					width = "double",
					min = 3,
					max = 60,
					step = 0.1,
					softMin = 3,
					softMax = 60,
					name = L["Font size"],
					desc = L["Font size of event window (default to 12.8)."],
					width = "normal",
					order = 2.1,
				},

				header03 = {
					type = "header",
					name = "",
					order = 3.01,
				},

				refresh_interval = {
					type = "range",
					width = "double",
					min = 1,
					max = 60,
					step = 1,
					softMin = 1,
					softMax = 60,
					name = L["Refresh interval"],
					desc = L["How frequent to refresh event window (default to 2 seconds)?"],
					width = "normal",
					order = 3.1,
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
