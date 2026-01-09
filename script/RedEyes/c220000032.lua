-- Red-Eyes Zombification
local s,id,o=GetID()
-- c220000032
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can target 1 "Red-Eyes" monster you control;
	it gains 1200 ATK until the end of this turn.
	]]--
	local e1a1=Effect.CreateEffect(c)
	e1a1:SetDescription(aux.Stringid(id,0))
	e1a1:SetType(EFFECT_TYPE_ACTIVATE)
	e1a1:SetCode(EVENT_FREE_CHAIN)
	e1a1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1a1)

	local e1a2=e1a1:Clone()
	e1a2:SetDescription(aux.Stringid(id,1))
	e1a2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1a2:SetTarget(s.e1tgt)
	e1a2:SetOperation(s.e1evt)
	c:RegisterEffect(e1a2)
	--[[
	During the Battle Phase, if you control a Level 7 or higher "Red-Eyes" Zombie monster,
	all monsters in your opponent's GY become Zombie monsters.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_ZOMBIE)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If a Dragon or Zombie monster(s) is Special Summoned from either GY to your field (even during the Damage Step):
	You can target 1 card your opponent controls;
	place it on top of the Deck.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsFaceup()
	and c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and s.e1fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1fil,tp,LOCATION_MZONE,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)

	Duel.SelectTarget(tp,s.e1fil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1b1=Effect.CreateEffect(c)
		e1b1:SetType(EFFECT_TYPE_SINGLE)
		e1b1:SetCode(EFFECT_UPDATE_ATTACK)
		e1b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1b1:SetValue(1200)
		tc:RegisterEffect(e1b1)
	end
end
function s.e2fil(c)
	return c:IsFaceup()
	and c:IsLevelAbove(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsRace(RACE_ZOMBIE)
	and c:IsMonster()
end
function s.e2con(e)
	return Duel.IsBattlePhase()
	and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_MZONE,0,1,nil)
end
function s.e2tgt(e,c)
	-- NECROVALLEY
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end
function s.e3fil(c,e,tp)
	return (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_ZOMBIE))
	and c:IsMonster()
	and c:IsLocation(LOCATION_MZONE)
	and c:IsControler(tp)
	and c:IsSummonLocation(LOCATION_GRAVE)
end
function s.e3con(e,tp,eg)
	return eg:IsExists(s.e3fil,1,nil,e,tp)
end
function s.e3con(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsOnField()
		and chkc:IsControler(1-tp)
		and chkc:IsAbleToDeck()
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,c)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.e3evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
