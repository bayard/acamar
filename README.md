### Acamar, auto-learning spam blocker.

Acamar learns player's chatting behavior and identify bots and spammers out from normal users. You don't need to configure keywords, just simply select the level of filtering and the addon will begin to learn, and as more information is learned, the filtering will become more accurate. 

In most cases, 90 minutes after running, 90% spammer should be identified and could be blocked, and >95% spammer should be identified after running for 1 day. Spammers may change their ways to bypass the filering, but hit rate will remain high unless spammers' behavior act like normal users and thus makes they become not so annoying. 

Highly talkative users may be identified as spammers, but they will be removed from blacklist after certain period of being less talkative, or filtering level could be set to less strict level to avoid blocking of these users.

Acamar introduces the concept of dynamic blacklist: Once identified as spammer, the player will be banned for hours or days or years, depends on how heavy the player spammed, and will gradually return to normal once stop spamming.

No configuration needed.

Filtering applies to following messages:
1. Channel chat (Guild, team and Raid messages were ignored,)
2. Say
3. Yell
4. Custom emote
5. Whisper

For addon developer: If you intent to use Acamar Spam Engine as your message filter, API code sample:

```lua
    local acamar_api = _G["AcamarAPIHelper"]
    if acamar_api ~= nil then
    	-- blocked: If the player with guid should be blocked.
    	-- spamscore: The spam score of the player. The greater, the player's 
    	-- behavior is more like a bot. Normally you don't need to use score unless 
    	-- you want to classified spam players into more specific groups. 1 is good
    	-- in most circumstances.
        local blocked, spamscore = acamar_api:IsBlock(guid)
        if blocked then
            -- add your code if player should be blocked
        end
    end
```

Acamar support both retail and classic of WoW. But not fully tested on retail version.

Triton@DaggerRidge(CN), 2020
https://github.com/bayard/acamar

------

### Acamar-自动学习垃圾消息屏蔽，支持魔兽世界怀旧版。

Acamar学习用户的聊天行为，从中辨识出正常玩家、垃圾发送者以及脚本。只需选择过滤的级别，插件就会自动学习，随着学习的信息越来越多，过滤就会变得越来越准确。

一般情况下，安装运行90分钟后，约90%的垃圾发送者和脚本将被识别出来并且可被屏蔽，一天后，垃圾信息玩家识别率可达95%以上。垃圾发送者可能会想办法绕过过滤，但是过滤效率将会保持在高水平上。除非这些垃圾发送者的行为越来越像正常玩家，当然这也让这些人的行为不那么烦人。

过于健谈的玩家可能会在一段时间内被识别为垃圾发送者，但随着他们变得不那么健谈，一段时间后他们会被识别为正常玩家。当然也可以通过调低过滤的严格级别来避免误伤。

Acamar引入一种概念叫动态黑名单，即：垃圾消息产生者根据行为轻重，会被禁止几小时、几天、甚至几年。当不在发垃圾消息后，会逐渐降低垃圾得分，直至移出黑名单。

无需配置。

过滤对下列消息有效：
1. 频道聊天，包括世界频道 (公会、组队、RAiD频道消息不会被过滤)
2. 说话
3. 大喊
4. 自定义表情
5. 私语

插件开发者可以通过下面的代码来使用Acamar API在自己开发的插件中过滤用户：

```lua
    local acamar_api = _G["AcamarAPIHelper"]
    if acamar_api ~= nil then
    	-- blocked: 用户guid是否被过滤掉
    	-- spamscore: 得分。用户行为越像垃圾信息发送者或脚本，得分越高。多数情况下，
    	-- 得分无需用到。如果要用，1 在多数情况下用来区隔正常用户和垃圾用户比较合适。
        local blocked, spamscore = acamar_api:IsBlock(guid)
        if blocked then
            -- 当用户被过滤掉的代码
        end
    end
```

Acamar 支持怀旧服和正式服。不过正式服上没有经过完全测试。

Triton@匕首岭, 2020
https://github.com/bayard/acamar

------

<sub>Acamar is 49 parsecs away from the sun, while Triton is only 0.00014567 parsecs.</sub>