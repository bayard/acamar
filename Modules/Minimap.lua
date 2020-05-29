local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local AcamarMinimap = addon:NewModule("AcamarMinimap", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

local private = {}


function AcamarMinimap:OnInitialize()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)

    if LDB then
        local MinimapBtn = LDB:NewDataObject("AcamarBtn", {
            type = "launcher",
    		text = addonName,
            icon = "Interface\\AddOns\\Acamar\\Media\\acamar",

            OnClick = function(_, button)
                if button == "LeftButton" then 
                    addon:UIToggle()
                end
            end,

            OnTooltipShow = function(tt)
                tt:AddLine(addonName)
                tt:AddLine(L["|cffffff00Click|r to toggle the Acamar main window."])
            end,

            OnLeave = HideTooltip
        })
        if LDBIcon then
            LDBIcon:Register(addonName, MinimapBtn, addon.db.global.minimap)
        end
    end
end
