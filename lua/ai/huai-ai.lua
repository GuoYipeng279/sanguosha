-- 界徐盛暂时采用烈弓，旋风ai
sgs.ai_skill_invoke.jiexushengPojun = sgs.ai_skill_invoke.liegong
sgs.ai_skill_invoke.jiexushengPojunHit = sgs.ai_skill_invoke.liegong
sgs.ai_card_intention.jiexushengPojun = sgs.ai_card_intention.XuanfengCard



sgs.ai_skill_invoke.Yuqi = true
sgs.ai_skill_askforag.Yuqi = function(self, card_ids)
    local room = self.player:getRoom()
	local cards = {}
	for _, card_id in ipairs(card_ids) do
		table.insert(cards, sgs.Sanguosha:getCard(card_id))
	end
    self:sortByCardNeed(cards)
    if self.player:getTag("yuqigive"):toString()=="give" and 
        not self.player:isFriend(self.player:getTag("yuqigiveto"):toDamage().to) then
        local msg = sgs.LogMessage()
        msg.type = sgs.QVariant("gghere"):toString()
        room:sendLog(msg)
        if self.player:getTag("refusable"):toInt()==1 then return -1 end
        return cards[1]:getEffectiveId()
    else return cards[#cards]:getEffectiveId() end
end
sgs.ai_skill_invoke.Shanshen = true
sgs.ai_skill_invoke.Xianjing = true
sgs.ai_skill_choice.Shanshen = function(self, choices)
    if self.player:getMark("@Yuqi4")+2 <= self.player:getMark("@Yuqi2") and self.player:getMark("@Yuqi4") < 4 then return "yuqitake" end
    if self.player:getMark("@Yuqi1") <= self.player:getMark("@Yuqi2") and self.player:getMark("@Yuqi1") < 4 then return "yuqirange" end
    if self.player:getMark("@Yuqi2") < 4 then return "yuqiget" end
    return sgs.ai_skill_choice.Xianjing(self, choices)
end
sgs.ai_skill_choice.Xianjing = function(self, choices)
    -- self.player:drawCards(1)
    -- self.player:drawCards(self.player:getMark("@Yuqi4")+1)
    if self.player:getMark("@Yuqi4")+1 <= self.player:getMark("@Yuqi2") and self.player:getMark("@Yuqi4") < 5 then return "yuqitake" end
    -- self.player:drawCards(1)
    if self.player:getMark("@Yuqi1") <= self.player:getMark("@Yuqi2") and self.player:getMark("@Yuqi1") < 5 then return "yuqirange" end
    -- self.player:drawCards(1)
    if self.player:getMark("@Yuqi2") < 5 then return "yuqiget" end
    -- self.player:drawCards(1)
    return "yuqigive"
end

sgs.ai_skill_choice.zhuni = function(self, choices)
    if self:isFriend(self.room:getLord()) then return choices[#choices] end
    return choices[0]
end




sgs.ai_skill_invoke.meihun = function(self, data)
    return #self.enemies > 0
end
sgs.ai_skill_invoke.GetPeach = function(self, data)
    local dying = data:toDying()
    return self:isFriend(dying)
end
sgs.ai_skill_use["@meihun"] =function(self)
    -- local room = self.player:getRoom()
    self:sort(self.enemies,"handcard", true)
    for _, p in ipairs(self.enemies) do
        if not p:isKongcheng() then 
            return "#meihunCard:.:->"..p:objectName()
        end
    end
    return nil
end
sgs.ai_skill_suit.meihunCard = function(self)
    if self.player:getHp() <= 1 and self.player:getPhase() ~= sgs.Player_Finish and not #(self.friends_noself) == 0 then return sgs.Card_Diamond end
    if self.player:getHp() <= 2 then return sgs.Card_Heart end
    if self.player:getPhase() ~= sgs.Player_Finish then return sgs.Card_Diamond end
	local all_cards = self.player:getCards("h")
    suits = sgs.IntList()
	for _, card in sgs.qlist(all_cards) do suits:append(card:getSuit()) end
    if suits:contains(sgs.Card_Heart) then return sgs.Card_Heart end
    if suits:contains(sgs.Card_Diamond) then return sgs.Card_Diamond end
    if suits:contains(sgs.Card_Spade) then return sgs.Card_Spade end
    if suits:contains(sgs.Card_Club) then return sgs.Card_Club end
end
sgs.ai_playerchosen_intention.meihun = function(self)
    if self.player:getHp() <= 1 and self.player:getPhase() ~= sgs.Player_Finish then return -80 end
    return 80
end
sgs.ai_skill_use_func["#meihunCard"] = function(card, use, self)
    local lis
    if self.player:getHp() <= 1 and self.player:getPhase() ~= sgs.Player_Finish and #(self.friends_noself) > 0 then
        self:sort(self.friends_noself,"handcard", true)
        lis = self.friends_noself
    else
        self:sort(self.enemies,"handcard", true)
        lis = self.enemies
    end
	if lis then
		if use.to then use.to:append(lis[1]) end
	end
	use.card = card
	return
end

local rende_skill = {}
rende_skill.name = "luanosrende"
table.insert(sgs.ai_skills, rende_skill)
rende_skill.getTurnUseCard = function(self)
    if self.player:hasUsed("#luanosrendeCard") then return end
    if #(self.enemies) < 1 then return end
    local room = self.player:getRoom()
    if room:getAllPlayers():length() <= 2 then return end
	-- local archery = sgs.Sanguosha:cloneCard("archery_attack")
	local first_found, second_found = false, false
	local first_card, second_card
	if self.player:getHandcardNum() >= 2 then
		local cards = self.player:getHandcards()
		local same_suit = false
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		local useAll = true
        local archeryattack = nil
		for _, fcard in ipairs(cards) do
            for _, scard in ipairs(cards) do
                if fcard ~= scard and scard:getSuit() == fcard:getSuit() then
                    local card_str = ("#luanosrendeCard:%d+%d:"):format(fcard:getId(), scard:getId())
                    archeryattack = sgs.Card_Parse(card_str)
                    return archeryattack
                end
            end
		end
	end
end

sgs.ai_playerchosen_intention.luanosrende = 10
sgs.ai_use_priority.luanosrendeCard = 100
sgs.ai_skill_use_func["#luanosrendeCard"] = function(card, use, self)
	self:sort(self.enemies, "huoxin") -- 按手牌数从小到大排序
	if self.enemies[1] and use.to then
        use.to:append(self.enemies[1])
        if self.enemies[2] and use.to then
            use.to:append(self.enemies[2])
        else
            local players = self.player:getRoom():getAllPlayers()
            for _,p in sgs.qlist(players) do
                if p ~= self.player and p ~= self.enemies[1] then
                    use.to:append(p)
                end
            end
        end
	end
    use.card = card
	return
end




sgs.ai_playerchosen_intention.congjian = -80
sgs.ai_skill_cardask["@congjian"] = function(self, data)
	local all_cards = self.player:getCards("h")
	for _, card in sgs.qlist(all_cards) do
        if card:getTypeId() == sgs.Card_TypeEquip then return card:getEffectiveId() end
    end
end

local xiongluan_skill = {}
xiongluan_skill.name = "xiongluan"
table.insert(sgs.ai_skills, xiongluan_skill)
xiongluan_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@xiongluan") >= 1 then
		return sgs.Card_Parse("#XiongluanCard:.:")
	end
end

sgs.ai_skill_use_func["#XiongluanCard"] = function(card, use, self)
	local target = nil
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sort(self.enemies, "hp")
	local slashes = self:getCards("Slash")
	if #slashes < 1 then return end
	for _, enemy in ipairs(self.enemies) do
		local n = 0
		for _, slash in ipairs(slashes) do
			if self.player:canSlash(enemy, slash, false) and sgs.isGoodTarget(enemy, self.enemies, self, true) 
				and self:slashIsEffective(slash, enemy, self.player) and not (self:hasEightDiagramEffect(enemy) and not IgnoreArmor(self.player, enemy)) then
					n = n + 1
					if n >= enemy:getHp() then target = enemy break end
			end
		end
		if target then break end
	end
	if target == nil then return end
	use.card = card
	if use.to then use.to:append(target) end
end

sgs.ai_use_priority.XiongluanCard = sgs.ai_use_priority.Slash + 0.1
sgs.ai_use_value.XiongluanCard = 3


sgs.ai_skill_invoke.huilu = function(self, data)
    local room = self.player:getRoom()
    if self.player:hasSkill("huilu") then return false end
    local duyou
    for _,p in sgs.qlist(room:getOtherPlayers(self.player)) do
        if p:hasSkill("huilu") then duyou = p end
    end
    if self:isFriend(duyou) then
        return self.player:getHandcardNum() > self.player:getMaxHp()
    else return false end
end

sgs.ai_skill_use["@@huilu"] = function(self, prompt)
    local room = self.player:getRoom()
    local cards = self.player:getHandcards()
    cards = sgs.QList2Table(cards)
    self:sortByUseValue(cards,true)
    local card_ids = {}
    for i=1, math.floor(#cards/2) do
        table.insert(card_ids, cards[i]:getEffectiveId())
    end

    return "#huiluCard:" .. table.concat(card_ids, "+") .. ":"
end


local zhizui_skill = {}
zhizui_skill.name = "zhizui"
table.insert(sgs.ai_skills, zhizui_skill)
zhizui_skill.getTurnUseCard = function(self, inclusive)
	return not self.player:hasUsed('#zhizuiCard') and not self.player:hasSkill("huilu") and sgs.Card_Parse("#zhizuiCard:.:")
end
sgs.ai_skill_use_func["#zhizuiCard"] = function(card, use, self)
    local duyou = self.room:findPlayerBySkillName("huilu")
	local target = nil
	self:sort(self.enemies, "distance")
	if self.player:getHandcardNum() < 3 or duyou:getHandcardNum() < 7 or self.player:getMark("@huilu") > 0 then return end
	for _, enemy in ipairs(self.enemies) do
		if math.min(duyou:getHandcardNum()/3,self.player:getHandcardNum()) >= enemy:getHp()+enemy:getHandcardNum()/3 and
        not (self:hasEightDiagramEffect(enemy) and not IgnoreArmor(self.player, enemy))
         then target = enemy break end
	end
	if target == nil then return end
	use.card = card
	-- if use.to then use.to:append(target) end
end

sgs.ai_skill_askforag.zhizui = function(self, card_ids)
    return card_ids:at(0)
end
    



sgs.ai_skill_invoke.yuyi = function(self, data)
    local use = data:toCardUse()
    if not self:isFriend(use.to:at(0)) or not use.to:at(0):isAlive() then return false end
    local proxi_draw = math.min(use.to:at(0):getHp(), self.player:getHp())
    local proxi_discard = math.min(math.max(use.to:at(0):getHp(), self.player:getHp()),
        math.min(use.to:at(0):getHandcardNum(), self.player:getHandcardNum()))
    -- self.player:drawCards(2)
    return proxi_draw > proxi_discard
    -- if proxi_draw <= proxi_discard then return false end
    -- if not self.player:hasSkill("nichang") then return true end
    -- local suits_num, equip_num, num_num, hufu_num = nichang_envir(self)
    -- local score = nichang_score(self, self.player, suits_num, equip_num, num_num, hufu_num)
    -- return score > 3 or score < -10
end

sgs.ai_skill_choice.yuyi = function(self, choices)
    pt(self.room, "yuyi")
    local choices = choices:split("+")
    -- pt(self.player:getRoom(), type(choices))
    -- pt(self.player:getRoom(), "choicing"..self.player:getTag("yuyiDecide"):toString())
    if self.player:getTag("yuyiDecide"):toString() == "true" then
        return choices[#choices]
    else
        -- pt(self.player:getRoom(), "choicemin")
        return choices[1]
    end
    -- return sgs.QVariant(math.max(1,#choices:split("+")-2)):toString()
end

sgs.ai_skill_choice["edouCard"] = function(self, choices)
    -- pt(self.room, "fangpai")
    local lis = choices:split("+")
    if #lis >= 2 then table.remove(lis, "cancel") end
    -- if table.contains(lis, "nichang") and self.player:getPile("hufu"):length() < 3 then
    --     table.remove(lis, "nichang")
    --     choices = table.concat(lis, "+")
    -- end
    return sgs.ai_skill_choice.huashen(self, table.concat(lis, "+"))
end
sgs.ai_skill_choice["edouGiveCard"] = function(self, choices)
    pt(self.room, "Give0")
    if self.player:getTag("edouGiveFriend"):toBool() then
        return "cancel"
    end --交给友军不指定技能
    pt(self.room, "Give1")
    local lis = choices:split("+")
    if table.contains(lis, "nichang") then
        pt(room.self, "Givenic")
        pt(room.self, self.player:getTag("nichangValue"):toInt())
        if self.player:getTag("nichangValue"):toInt() >= 5 then
            pt(self.room, "GiveNichang")

            return "nichang"
        else
            pt(self.room, "GiveNull")
            table.remove(lis, "nichang") --若霓裳效果不强，不使用
        end
    end
    return lis[1]
end
sgs.ai_skill_choice["edouChangeCard"] = function(self, choices)
    return self.player:getTag("wantEdou"):toString()
end
-- sgs.ai_skill_choice.edou = sgs.ai_skill_choice.huashen
sgs.ai_use_value.Edou = 7
sgs.ai_keep_value.Edou = 6
local edou_skill = {}
edou_skill.name = "edou"
table.insert(sgs.ai_skills, edou_skill)
thinkEdouCard = function(self)
    local room = self.player:getRoom()
	-- local archery = sgs.Sanguosha:cloneCard("archery_attack")
    local like = {}
    if self.player:hasSkill("nichang") then
        -- 按照先选取场上武器，再从常见武器点数中选取
        liko = {1,13,2,3,5,12,6}
        local numbers = {}
        for i=1, 13 do table.insert(numbers,false) end
        for _,p in sgs.qlist(room:getAllPlayers()) do
            for _,e in sgs.qlist(p:getEquips()) do
                numbers[e:getNumber()] = true
            end
        end
        for i,n in ipairs(numbers) do
            if n then table.insert(like, i) end
        end
        for _,lik in ipairs(liko) do
            if not table.contains(like, lik) then table.insert(like, lik) end
        end
    end
	if not self.player:isKongcheng() then
        local subcards = {}
        local pile = sgs.IntList()
		local cards = {}
        local hufus = self.player:getPile("hufu")
        -- pt(room, "1")
        for _, c in sgs.qlist(hufus) do
            pile:append(sgs.Sanguosha:getCard(c):getNumber())
        end
        for _, c in sgs.qlist(self.player:getHandcards()) do
            pt(room, c:getNumber().."beforecheck")
            if pile:contains(c:getNumber()) then else
            pt(room, c:getNumber().."aftercheck")
            if self.player:hasSkill("nichang") and c:getTypeId() == sgs.Card_TypeEquip then
                table.insert(subcards, c:getId())
                pile:append(c:getNumber())
            else
                table.insert(cards, c)
            end
            end
        end
        -- pt(room, "2")
		self:sortByKeepValue(cards)
		local useAll = true
        local archeryattack = nil
        -- pt(room, "3")
        local msg = sgs.LogMessage()
        for i, n in ipairs(like) do
            if pile:contains(n) then else
                for j, fcard in ipairs(cards) do
                    if fcard:getNumber() ~= n then else
                    if #subcards + hufus:length() > self.player:getHp()*1.3 then break end
                    table.insert(subcards, fcard:getId())
                    break
                    end
                end
            end
        end
        -- pt(room, "4")
        if #subcards == 0 and self.player:getHandcardNum() > self.player:getMaxCards() then table.insert(subcards, cards[1]:getId()) end
        if #subcards > 0 then return "#edouCard:"..table.concat(subcards,"+")..":" end
    end
    return nil
end
thinkEdouChange = function(self)
    local pile = self.player:getPile("hufu")
    if pile:isEmpty() then return nil end
    local choices1 = self.room:getTag("edouTags"):toString():split("+")
    local choices2 = self.player:getTag("originalSkills"):toString():split("+")
    for _, sk in ipairs(choices2) do
        table.concat(choices1, sk)
    end
    local choices = table.concat(choices1,"+")
    pt(self.room, "change2"..choices)
    local want = sgs.ai_skill_choice.huashen(self, choices, data, false)
    pt(self.room, "want1")
    pt(self.room, want)
    pt(self.room, "want2")
    self.player:setTag("wantEdou", sgs.QVariant(want))
    if want ~= self.player:getTag("edouSkill"):toString() then
        pt(self.room, "want3")
        return "#edouChangeCard:"..pile:at(0)..":"
    end
    pt(self.room, "want4")
    return nil
end
thinkEdouGive = function(self)
    if self.player:hasSkill("nichang") and self.player:hasSkill("xieyou") then return end -- 糜夫人不会主动交出
    local min, who = 999, nil
    local room = self.room
    -- pt(room, "give1")
    for _,p in ipairs(self.friends_noself) do
        if p:hasSkill("kongcheng") then else
        if p:getHandcardNum() < min then
            min = p:getHandcardNum()
            who = p
        end
        end
    end
    -- pt(room, "give2")
    if who and min <= 1 and self.player:getHp() > 3 then
        self.player:setTag("edouGiveFriend", sgs.QVariant(true))
        return "#edouGiveCard:.:->"..who:objectName()
    end
    -- pt(room, "give3")
    local suits_num, equip_num, num_num, hufu_num = nichang_envir(self)
    -- pt(room, "give7")
    for _, p in ipairs(self.enemies) do
        -- pt(room, "give5")
        if nichang_score(self, p, suits_num, equip_num, num_num, hufu_num) > 20 or p:getMaxHp() < 3 then
            return "#edouGiveCard:.:->"..p:objectName()
        end
    end
    -- pt(room, "give4")
    return nil
end
edou_skill.getTurnUseCard = function(self)
    if self.player:getPhase() == sgs.Player_Play and self.player:hasUsed("#edouCard") or self.player:hasUsed("#edouGiveCard") or self.player:hasUsed("#edouChangeCard") then return end
    if not self.player:isAlive() then return edouGiveCard:clone() end
    local archeryattack
    pt(self.room, "thinkEdouChange")
    _edouCard = thinkEdouChange(self)
    pt(self.room, "thinkEdouGive")
    _edouCard = thinkEdouGive(self)
    if _edouCard ~= nil then archeryattack = sgs.Card_Parse(_edouCard) end
    pt(self.room, "thinkEdouCard")
    _edouCard = thinkEdouCard(self)
    if _edouCard ~= nil then archeryattack = sgs.Card_Parse(_edouCard) end
    return archeryattack
end

sgs.ai_use_priority.edouGiveCard = 99
sgs.ai_use_priority.edouCard = 100
--[[sgs.ai_skill_use_func["#edouGiveCard"] = function(card, use, self)
    local possible_list = self.friends_noself
    local to
    local min_wound, max_hp = 999, 0
    for _,p in ipairs(possible_list) do
        local wound, hp = p:getLostHp(), p:getHp()
        if wound < min_wound then
            to = p 
            min_wound = wound
        end
        if wound == min_wound then
            if hp > max_hp then
                to = p
                max_hp = hp
            end
        end
    end
	if to and use.to then
        use.to:append(to)
    else return end
    use.card = card
end]]
sgs.ai_skill_use_func["#edouCard"] = function(card, use, self)
    use.card = card
end
nichang_envir = function(self)
    local room = self.room
    local suits, numbers, hufu = {}, {}, {}
    local equip_num, num_num = 0,0
    for i=1, 13 do table.insert(numbers,false) end
    for i=1, 13 do table.insert(hufu,false) end
    for _,p in sgs.qlist(room:getAllPlayers()) do
        equip_num = equip_num + p:getEquips():length()
        for _,e in sgs.qlist(p:getEquips()) do
            local suit = sgs.Card_Suit2String(e:getSuit())
            if not table.contains(suits, suit) then table.insert(suits, suit) end
            numbers[e:getNumber()] = true
        end
    end
    for _,c in sgs.qlist(self.player:getPile("hufu")) do
        hufu[sgs.Sanguosha:getCard(c):getNumber()] = true
    end
    for _,c in ipairs(numbers) do
        if c then num_num = num_num + 1 end
    end
    local hufu_num = self.player:getPile("hufu"):length()
    local suits_num = #suits
    -- pt(room, table.concat({suits_num, equip_num, num_num, hufu_num},"+"))
    return suits_num, equip_num, num_num, hufu_num
end
nichang_score = function(self, p, suits_num, equip_num, num_num, hufu_num)
    local score = 0
    score = score - math.min(equip_num, 8)
    score = score - suits_num*2
    score = score - 6*p:getLostHp()
    if not (p:isWounded()) then score = score + 5 end
    score = score + hufu_num
    if hufu_num == 0 then score = score - 5 end
    if hufu_num < 4 then score = score + hufu_num end
    if hufu_num >= 6 then score = score + 10 end
    if hufu_num >= 12 then score = score + 30 end
    score = score - 2*p:getMaxHp()
    score = score + 3*p:getHp()
    local multiplier = 0
    if self:isFriend(p) then multiplier = 1 end
    if self:isEnemy(p) then multiplier = -1 end
    score = score * multiplier
    score = score + p:getHandcardNum()
    if p:isLord() then score = score + 8 end
    -- pt(self.room, "eeee"..score)
    return score
end
sgs.ai_skill_use["@edou"] = function(self)
    local room = self.player:getRoom()
    local caopi = self.room:findPlayerBySkillName("xingshang")
    if not self.player:isAlive() or caopi and self.player:getHp() <= 1 then
        -- 已死亡，考虑给出【阿斗】
        local high = 0
        local to = nil
        -- 考虑霓裳负面效果
        if table.contains(room:getTag("edouTags"):toString():split("+"), "nichang") then
            -- pt(room, "dead1")
            local suits_num, equip_num, num_num, hufu_num = nichang_envir(self)
            -- local suits_num, equip_num, num_num, hufu_num = paras[1], paras[2],paras[3],paras[4]
            pt(room, "dead2")
            for _,p in sgs.qlist(room:getOtherPlayers(self.player)) do
                score = nichang_score(self, p, suits_num, equip_num, num_num, hufu_num)
                -- pt(room, "dead3")
                if score > high then
                    to = p
                    high = score
                end
            end
            pt(room, "dead "..high)
            self.player:setTag("nichangValue", sgs.QVariant(math.floor(high)))
        end
        -- 霓裳负面不足，考虑交给友军
        if high < 8 then
            local max_hp = 0
            for _,p in ipairs(self.friends_noself) do
                if p:getLostHp() and p:getHp() > max_hp then
                    to = p
                    max_hp = p:getHp()
                end
            end
        end
        if to ~= nil then
            self.player:setTag("edouGiveFriend", sgs.QVariant(self:isFriend(to)))
            return "#edouGiveCard:.:->"..to:objectName()
        end
    else
        -- pt(room, "think")
        _edouCard = thinkEdouCard(self) -- 考虑放牌
        -- pt(room, _edouCard)
        if _edouCard ~= nil then return _edouCard end
    end
    return nil
end
pt = function(room, x)
    local msg = sgs.LogMessage()
    msg.type = x
    room:sendLog(msg)
end
sgs.ai_skill_askforag.nichang = function(self, card_ids)
	local kind
    local room = self.player:getRoom()
    -- pt(room, "1")
    if self.player:getTag("nichang"):toString() == "slash" then kind = "Slash" end
    if self.player:getTag("nichang"):toString() == "jink" then kind = "Jink" end
    local have = false
    for _,c in sgs.qlist(self.player:getHandcards()) do
        if c:isKindOf(kind) then have = true break end
    end
    -- pt(room, "2")
    local id = -1
    for _,c in sgs.list(card_ids) do
        -- pt(room, "ncag2"..sgs.Sanguosha:getCard(c):objectName())
        if sgs.Sanguosha:getCard(c):isKindOf(kind) then id = c break end
    end
    if have or id == -1 then
        self:sortByCardNeed(card_ids)
        return card_ids[#card_ids]:getEffectiveId()
    else
        -- pt(room, "3")
        return id
    end
end

sgs.ai_skill_use["@zhusha"] = function(self)
    local room = self.room
    pt(self.room, "zhusha1")
    local who = room:getTag("zhushaTarget"):toDamage().to
    pt(self.room, "zhusha21")
    if not self:isEnemy(who) or self.player:isKongcheng() then return nil end
    pt(self.room, "zhusha22")
    local cards = sgs.QList2Table(self.player:getHandcards())
    pt(self.room, "zhusha23")
    self:sortByKeepValue(cards)
    pt(self.room, "zhusha24")
    for _, fc in ipairs(cards) do
        pt(self.room, "zhusha3")
        local id1 = fc:getEffectiveId()
        if self.player:getHp() >= 2 and who:isLord() then
            pt(self.room, "zhusha4")
            for _, sc in ipairs(cards) do
                local id2 = sc:getEffectiveId()
                if id1 ~= id2 and sc:getSuit() ~= fc:getSuit() then
                    return "#zhushaCard:"..table.concat({id1, id2}, "+")..":"
                end
            end
        end
        pt(self.room, "zhusha5")
        return "#zhushaCard:"..id1..":"
    end
end
