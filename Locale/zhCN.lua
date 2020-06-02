local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN")
if not L then return end
------------------------------------------------------------------------------
L["|cffffff00Click|r to toggle the Acamar main window."] = "|cffffff00点击|r图标打开Acamar控制窗口"

L["Enter /acamar for Acamar engine main interface"] = "输入 /acamar 打开Acamar自学习垃圾消息插件控制窗口"
L["Found new possible spammer: "] = "发现新的垃圾消息发送者："
L["'s spam score increased."] = "的垃圾得分增加了。"
L["Currently banned players:"] = "当前屏蔽的玩家："
L["Top 500 spammers with spam score greater than "] = "垃圾得分最高500名玩家，得分超过"
L["Total players in banned list: "] = "屏蔽列表的总玩家："
L["Learning in progress ..."] = "正在学习玩家垃圾消息行为......"
L["Top players with spam score. Max "] = "有垃圾消息嫌疑的玩家排名，最多显示数量："
L["The list changes along with the learning progress."] = "随着系统学习的深入，这个列表会动态变化。"
L["Total players in the list: "] = "此列表的总玩家："
L["Resetting DB and learning enging..."] = "[慎点] 重置所有学习的数据，重新开始学习。"
L["Reset and re-learn"] = "重置数据以重新学习"
L["Reset DB to initial status and begin to re-learn players' behavior."] = "[慎点] 将学习的数据清空，重新开始学习。"
L["Top 500 spammers"] = "前500名垃圾信息发送者"
L["Print current banned player list in chat window."] = "将当前被被屏蔽的用户列表发送到聊天窗口。"
L["Top 500 spammer list"] = "前500名垃圾信息发送者："

L["Filtering Level"] = "过滤级别"
L["Set messages filtering level"] = "选择过滤级别"
L["Most strict level with minimum spam"] = "最严格过滤"
L["Bots, spammers, annoying senders and talkative players away"] = "脚本、垃圾信息、烦人以及多话的玩家走开"
L["Block bots, spammers and annoying messages"] = "禁止脚本、垃圾信息、烦人的玩家"
L["Block bots and spammers"] = "禁止脚本、垃圾信息"
L["Block bots only"] = "禁止脚本型玩家"
L["Turn On Engine"] = "启用Acamar引擎"
L["Turn on messages filtering and learning engine. If turn off, messages will not be filtered."] = "如果关闭，消息过滤及学习都将被停止。"
L["Engine Settings"] = "基本设置"
L["Advanced Settings"] = "高级设置"
L["Spam score"] = "评分列表"
L["About"] = "关于"
L["ABOUT_INFO"] = "|cffca99ffAcamar|r 距离太阳49pc，|cffca99ffTriton|r才0.00014567pc。"
L["Do not disturb"] = "尽量勿扰模式"
L["Enable to bypass printing of progress messages (like talkative player added into learning) in chat window."] = "如果启用，类如多话玩家被加入学习等信息将不会打印到聊天窗口。"

L["Regular(LFG, World, Trade, etc.)"] = "常规频道(寻找团队、世界频道、交易频道等)"
L["Regular and party/raid"] = "常规以及小队/团队频道"
L["Regular and guild"] = "常规以及公会频道"
L["Regular, guild and party/raid"] = "常规、公会以及小队/团队频道" 
L["Filtering Channels"] = "过滤哪些频道"
L["Select channels to filtered"] = "选择要过滤的频道"
L["FILTER_CHANNEL_NOTE"] = "为了不遗漏重要消息，公会官员以及团队领袖频道任何情况下都不会过滤。"

L["Message filtering running ..."] = "开始进行消息过滤..."
L["Message filtering stopped."] = "消息过滤停止。"

L["Rewrite messages"] = "精简消息"
L["[RW] "] = "[简] "
L["REWRITE_DESC"] = "将重复和啰嗦的消息精简，这类消息前面会添加|cff00cccc[简]|r的标志。消息量大的时候cpu负载会略高。"

-- logs
L["Acamar control window opened."] = "Acamar控制窗口已打开。"
L["At current level, block spam score set to: "] = "当前过滤级别对应的垃圾得分为："
L["'s behavior return normal and removed from the learning process."] = "的行为恢复正常，所以停止学习该玩家的行为。"
L[" was talkative in last hour and added to learning process."] = "最近话多起来，已关注其聊天信息。"
L[" was talkative in last day and added to learning process."] = "最近一天话多起来，已关注其聊天信息。"
L["Performing analysis on user behavior ..."] = "正在分析用户聊天行为数据..."
L["Performing optimization on learning DB ..."] = "正在优化数据库..."
L["Chat messages filtering started."] = "聊天信息过滤启用。"
L["Chat messages filtering stopped, but learning engine still running."] = "聊天信息过滤停止，不过学习引擎继续运行。"
L["Turn on learning engine..."] = "打开学习引擎..."
L["Turn off learning engine..."] = "关闭学习引擎..."

-- app info
L["ADDON_INFO"] = '|cffca99ffAcamar|r 自学习垃圾消息屏蔽插件。支持WoW怀旧版。'

L["AUTHOR_INFO"] = '|cffca99ffAcamar|r 学习用户的聊天行为，从中辨识出正常玩家、垃圾发送者以及脚本。只需选择过滤的级别，随着学习的信息越来越多，过滤就会变得越来越准确。\n\n' .. 
"可以使用|cffca99ff /acamar |r命令或者小地图图标打开小控制窗口来暂停和启用过滤。" ..
'\n\nhttps://github.com/bayard/acamar\n|cffca99ffTriton|r@匕首岭 2020'

-- EOF
