-- Gilford the Legend of Blazing Red Lightning
local s,id,o=GetID()
-- c220000014
function s.initial_effect(c)
	--[[
	[HOPT]
	You can Special Summon this card (from your hand) by sending 3 other "Red-Eyes" monsters from your hand to the GY.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,{id,0})
	e1:SetValue(1)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	When Summoned this way:
	Destroy as many monsters your opponent controls as possible,
	and if you do, inflict 500 damage to your opponent for each monster destroyed by this effect.
	]]--
	local e1b=Effect.CreateEffect(c)
	e1b:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetCondition(s.e1bcon)
	e1b:SetTarget(s.e1btgt)
	e1b:SetOperation(s.e1bevt)
	c:RegisterEffect(e1b)
	--[[
	[HOPT]
	If this card battles, during damage calculation:
	This card gains ATK equal to half the ATK of the monster your opponent controls with the highest ATK (your choice, if tied).
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is destroyed by battle or an opponent's card effect:
	You can return all Equip Spells and Normal Traps that have an effect to equip themselves to a monster in your GY to the Deck.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsMonster()
	and c:IsSetCard(SET_RED_EYES)
	and c:IsAbleToGraveAsCost()
end
function s.e1con(e,c)
	if c==nil then return true end

	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_HAND,0,e:GetHandler())

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and rg:GetCount()>2
	and aux.SelectUnselectGroup(rg,e,tp,3,3,nil,0)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_HAND,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)

	if g:GetCount()>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	
	if not g then return end

	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.e1bcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.e1btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end

	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0,nil)
end
function s.e1bevt(e,tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)

	local atk=0
	if g:GetCount()>0 then
		atk=g:GetFirst():GetAttack()/2
	end

	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,atk)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)

		if g:GetCount()>0 then
			local atk=g:GetFirst():GetAttack()/2

			if atk>0 then
				local e2b=Effect.CreateEffect(c)
				e2b:SetType(EFFECT_TYPE_SINGLE)
				e2b:SetCode(EFFECT_UPDATE_ATTACK)
				e2b:SetValue(atk)
				c:RegisterEffect(e2b)
			end
		end
	end
end
function s.e3con(e,tp)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
function s.e3fil(c)
	-- Equip Card Traps
	return ((c:IsNormalTrap()
	and (c:IsCode(259314)
	or c:IsCode(2542230)
	or c:IsCode(6112401)
	or c:IsCode(6691855)
	or c:IsCode(13235258)
	or c:IsCode(13317419)
	or c:IsCode(15684835)
	or c:IsCode(18096222)
	or c:IsCode(18446701)
	or c:IsCode(20989253)
	or c:IsCode(21350571)
	or c:IsCode(23122036)
	or c:IsCode(26647858)
	or c:IsCode(29867611)
	or c:IsCode(36591747)
	or c:IsCode(37390589)
	or c:IsCode(38643567)
	or c:IsCode(43004235)
	or c:IsCode(43405287)
	or c:IsCode(47819246)
	or c:IsCode(49551909)
	or c:IsCode(51686645)
	or c:IsCode(53656677)
	or c:IsCode(54451023)
	or c:IsCode(55262310)
	or c:IsCode(57135971)
	or c:IsCode(57470761)
	or c:IsCode(58272005)
	or c:IsCode(59490397)
	or c:IsCode(62091148)
	or c:IsCode(63049052)
	or c:IsCode(66984907)
	or c:IsCode(68054593)
	or c:IsCode(68540058)
	or c:IsCode(75361204)
	or c:IsCode(75987257)
	or c:IsCode(80143954)
	or c:IsCode(89812483)
	or c:IsCode(91152455)
	or c:IsCode(92650018)
	or c:IsCode(93473606)
	or c:IsCode(93655221)
	or c:IsCode(97182396)
	or c:IsCode(98239899)))
	or c:IsEquipSpell())
	and c:IsAbleToDeck()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_GRAVE,0,1,e:GetHandler())
	end

	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function s.e3evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
