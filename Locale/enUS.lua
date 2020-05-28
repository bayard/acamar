local addonName, _ = ...
local silent = true
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true, silent)
if not L then return end
------------------------------------------------------------------------------

L["|cffffff00Click|r to toggle the triton main window."] = true

L["Filtering Level"] = true
L["Set messages filtering level"] = true
L["Most strict level with minimum spam"] = true
L["Bots, spammers, annoying senders and talkative players away"] = true
L["Block bots, spammers and annoying messages"] = true
L["Block bots and spammers"] = true
L["Block bots only"] = true
L["Turn On Engine"] = true
L["Turn on messages filtering and learning engine. If turn off, messages will not be filtered."] = true

L["ADDON_INFO"] = '|cffca99ffAcamar|r machine-learning spam blocker addon for WoW.'

L["AUTHOR_INFO"] = '|cffca99ffAcamar|r learns user chatting behavior and identify bots and spammers out from normal users, and as more information is learned, the filtering will become more accurate.\n\n' .. 
"You are use /acamar command or click minimap icon to open tiny control window to pause/resume filtering." ..
'\n\nhttps://github.com/bayard/acamar\n|cffca99ffTriton|r@匕首岭 2020'

-- EOF
