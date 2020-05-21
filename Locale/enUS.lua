local addonName, _ = ...
local silent = true
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true, silent)
if not L then return end
------------------------------------------------------------------------------

L["|cffffff00Click|r to toggle the triton main window."] = true

L["TRITON"] = "Triton";

L["Add new keywords"] = true
L["Keywords (, & - may be used)"] = true
L["Add"] = true
L["Back"] = true
L["Remove all keywords"] = true
L["Keywords will be removed!"] = true
L["Remove"] = true
L["Cancel"] = true
L["Keywords could not be empty"] = true
L["Edit keywords"] = true
L["Confirm"] = true
L["@"] = true
L["|cffffff00Click|r to toggle the triton main window."] = true
L["Message alive time"] = true
L["How long will message be removed from event (default to 120 seconds)?"] = true
L["Font size"] = true
L["Font size of event window (default to 12.8)."] = true
L["Refresh interval"] = true
L["How frequent to refresh event window (default to 2 seconds)?"] = true
L["enter /triton for main interface"] = true

L["Choose operation: |cff00cccc"] = true
L["Block user"] = true
L["Add friend"] = true
L["Copy user name"] = true
L["User details"] = true
L["Whisper"] = true
L["|cffff9900Cancel"] = true

L["ADDON_INFO"] = '|cffca99ffTriton|r organize messages into topics for you to track events of LFG, gold raid and others you may interested.'

L["AUTHOR_INFO"] = 'Hint: When entering keywords, using comma (|cff00cccc.|r) to seperate keywords. |cff00cccc&|r can be used as "|cff00ccccand|r" operator, |cff00cccc-|r can be used a "|cff00ccccnot|r" operator. Special class keyword：|cff00ccccclass:warlock|r refer to warlock, etc. Sender name can be used in search and case ignored.\n\n' .. 
'For Example:\n' .. 
'OYN&LFG: must include |cff00ccccOYN|r and |cff00ccccLFG|r.\n' ..
'OYN-Bad-fxxk: must include |cff00ccccOYN|r but none of |cff00ccccBad|r or |cff00ccccfxxk|r.\n' ..
'OYN,MC,BWL: must include one of |cff00ccccOYN|r, |cff00ccccMC|r and |cff00ccccBWL|r.' .. 
'\n\nhttps://github.com/bayard/triton\n|cffca99ffTriton|r@匕首岭 2020'

-- EOF
