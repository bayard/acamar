local addonName, _ = ...
local silent = true
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true, silent)
if not L then return end
------------------------------------------------------------------------------

L["|cffffff00Click|r to toggle the acamar main window."] = true

L["Enter /acamar for Acamar engine main interface"] = true
L["Found new possible spammer: "] = true
L["'s spam score increased."] = true
L["Currently banned players:"] = true
L["Top 500 spammers with spam score greater than "] = true
L["Total players in banned list: "] = true
L["Learning in progress ..."] = true
L["Top players with spam score. Max "] = true
L["The list changes along with the learning progress."] = true
L["Total players in the list: "] = true
L["Resetting DB and learning enging..."] = true
L["Reset and re-learn"] = true
L["Reset DB to initial status and begin to re-learn players' behavior."] = true
L["Top 500 spammers"] = true
L["Print current banned player list in chat window."] = true
L["Top 500 spammer list"] = true

L["Filtering Level"] = true
L["Set messages filtering level"] = true
L["Most strict level with minimum spam"] = true
L["Bots, spammers, annoying senders and talkative players away"] = true
L["Block bots, spammers and annoying messages"] = true
L["Block bots and spammers"] = true
L["Block bots only"] = true
L["Turn On Engine"] = true
L["Turn on messages filtering and learning engine. If turn off, messages will not be filtered."] = true
L["Engine Settings"] = true
L["Advanced Settings"] = true
L["Spam score"] = true
L["About"] = true
L["ABOUT_INFO"] = "|cffca99ffAcamar|r is 49 parsecs away from the sun, while |cffca99ffTriton|r is only 0.00014567 parsecs."
L["Do not disturb"] = true
L["Enable to bypass printing of progress messages (like talkative player added into learning) in chat window."] = true

L["Regular(LFG, World, Trade, etc.)"] = true
L["Regular and party/raid"] = true
L["Regular and guild"] = true
L["Regular, guild and party/raid"] = true
L["Filtering Channels"] = true
L["Select channels to filtered"] = true
L["FILTER_CHANNEL_NOTE"] = "Guid officer and RAID leader channels would not be filtered in any case."

L["Message filtering running ..."] = true
L["Message filtering stopped."] = true

L["Rewrite messages"] = true
L["[RW] "] = true
L["REWRITE_DESC"] = "Rewrite messages with repeat patterns, could affect performance in heavy message traffic. Rewritten messages displayed with a mark: [RW]"

L["Bypass friends"] = true
L["Do not filter members of guild, party/raid, and myself."] = true

L["White list"] = true
L["Enter player's name list to bypass filtering:"] = true
L["One player in one single line"] = true

-- logs
L["Acamar control window opened."] = true
L["At current level, block spam score set to: "] = true
L["'s behavior return normal and removed from the learning process."] = true
L[" was talkative in last hour and added to learning process."] = true
L[" was talkative in last day and added to learning process."] = true
L["Performing analysis on user behavior ..."] = true
L["Performing optimization on learning DB ..."] = true
L["Chat messages filtering started."] = true
L["Chat messages filtering stopped, but learning engine still running."] = true
L["Turn on learning engine..."] = true
L["Turn off learning engine..."] = true

-- app info
L["ADDON_INFO"] = '|cffca99ffAcamar|r auto-learning spam blocker.'

L["AUTHOR_INFO"] = '|cffca99ffAcamar|r learns user chatting behavior and identify bots and spammers out from normal users, and as more information is learned, the filtering will become more accurate.\n\n' .. 
"You are use /acamar command or click minimap icon to open tiny control window to pause/resume filtering." ..
'\n\nhttps://github.com/bayard/acamar\n|cffca99ffTriton|r@匕首岭 2020'

-- EOF
