local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN")
if not L then return end
------------------------------------------------------------------------------

L["ADDON_INFO"] = '|cffca99ffAcamar|r 自学习垃圾消息屏蔽插件。支持WoW怀旧版。'

L["Filtering Level"] = "过滤级别"
L["Set messages filtering level"] = "选择过滤级别"
L["Most strict level with minimum spam"] = "最严格过滤"
L["Bots, spammers, annoying senders and talkative players away"] = "脚本、垃圾信息、烦人以及多话的玩家走开"
L["Block bots, spammers and annoying messages"] = "禁止脚本、垃圾信息、烦人的玩家"
L["Block bots and spammers"] = "禁止脚本、垃圾信息"
L["Block bots only"] = "禁止脚本型玩家"
L["Turn On Engine"] = "消息过滤及学习引擎"
L["Turn on messages filtering and learning engine. If turn off, messages will not be filtered."] = "如果关闭，消息过滤及学习都将被停止。"

L["AUTHOR_INFO"] = '|cffca99ffAcamar|r 学习用户的聊天行为，从中辨识出正常玩家、垃圾发送者以及脚本。只需选择过滤的级别，随着学习的信息越来越多，过滤就会变得越来越准确。\n\n' .. 
'\n\nhttps://github.com/bayard/acamar\n|cffca99ffTriton|r@匕首岭 2020'

-- EOF
