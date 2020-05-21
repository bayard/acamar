local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN")
if not L then return end
------------------------------------------------------------------------------

L["|cffffff00Click|r to toggle the triton main window."] = "|cffffff00点击|r显示Triton消息分类窗口"
L["TRITON"] = "Triton";

L["Add new keywords"] = "添加新关键字"
L["Keywords (, & - may be used)"] = "&-分别表示and和not，多关键字用逗号隔开"
L["Add"] = "添加"
L["Back"] = "返回"
L["Remove all keywords"] = "删除所有关键字"
L["Keywords will be removed!"] = "关键字将全部删除！"
L["Remove"] = "删除"
L["Cancel"] = "取消"
L["Keywords could not be empty"] = "关键字不能为空！"
L["Edit keywords"] = "编辑关键字"
L["Confirm"] = "确认"
L["@"] = "@"
L["|cffffff00Click|r to toggle the triton main window."] = "|cffffff00点击|r 打开Triton窗口"
L["Message alive time"] = "消息留存时长"
L["How long will message be removed from event (default to 120 seconds)?"] = "窗口中消息将保留多少秒（缺省120）。"
L["Font size"] = "字体大小"
L["Font size of event window (default to 12.8)."] = "窗口的字体大小（缺省12.8）,改变此项后请关闭窗口再重新打开。"
L["Refresh interval"] = "更新频率"
L["How frequent to refresh event window (default to 2 seconds)?"] = "窗口刷新频率（缺省2秒）。"
L["enter /triton for main interface"] = "输入 /triton 打开 Triton 开始跟踪事件"

L["Choose operation: |cff00cccc"] = "选择操作：|cff00cccc"
L["Block user"] = "屏蔽此用户"
L["Add friend"] = "加为好友"
L["Copy user name"] = "复制用户名"
L["User details"] = "查看用户详情"
L["Whisper"] = "发私信"
L["|cffff9900Cancel"] = "|cffff9900取消"

L["ADDON_INFO"] = '|cffca99ffTriton|r 将杂乱的聊天消息组织成清晰明了的主题，无论是关注金团还是寻找队伍等， 从此变得非常简单。'

L["AUTHOR_INFO"] = '提示：当输入关键字，可用逗号隔开多个关键字。|cff00cccc&|r符号表示|cff00cccc与|r，|cff00cccc-|r符号表示|cff00cccc非|r。搜索包括消息、职业及玩家名字，大小写忽略。特殊职业关键字，如：|cff00ccccclass:warlock|r表示术士。\n\n' .. 
'举例：\n' .. 
'BWL&金团：表示消息中必须包括|cff00ccccBWL|r和|cff00cccc金团|r。\n' ..
'BWL-骗子：表示消息中必须有|cff00ccccBWL|r，但不包括|cff00cccc骗子|r。\n' ..
'BWL,MC：表示消息中如果包括|cff00ccccBWL|r或者|cff00ccccMC|r。' .. 
'\n\nhttps://github.com/bayard/triton\n|cffca99ffTriton|r@匕首岭 2020'

-- EOF
