-- Red-Eyes, Dragon of the Deep
local s,id,o=GetID()
-- c220000006
function s.initial_effect(c)
	-- 1 Level 7 “Red-Eyes” monster + 1 Warrior monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- All monsters you control gain 400 ATK/DEF.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(400)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- Reduce the Level of all monsters in your hand and on the field by 1.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(aux.TRUE)
	e3:SetValue(-1)
	c:RegisterEffect(e3)
	-- All “Red-Eyes” monsters you control are unaffected by Spell effects.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3b))
	e4:SetValue(s.e4fil)
	c:RegisterEffect(e4)
	--[[
	[SOPT]
	Once per turn: You can discard 1 card; this card can attack directly this turn.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetCost(s.e5cst)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect:
	You can Special Summon 1 Level 6 or lower “Red-Eyes” or Warrior monster from your Deck or GY.
	]]--
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,0})
	e6:SetCondition(s.e6con)
	e6:SetTarget(s.e6tgt)
	e6:SetOperation(s.e6evt)
	c:RegisterEffect(e6)
end
-- Archetype : Red-Eyes
s.listed_series={0x3b}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsSetCard(0x3b)
	and c:IsLevel(7)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR)
end
function s.e4fil(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
function s.e5cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.e5evt(e)
	local c=e:GetHandler()

	local e5b=Effect.CreateEffect(c)
	e5b:SetDescription(3205)
	e5b:SetType(EFFECT_TYPE_SINGLE)
	e5b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e5b:SetCode(EFFECT_DIRECT_ATTACK)
	e5b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e5b)
end
function s.e6fil(c,e,tp)
	return c:IsLevelBelow(6)
	and (c:IsSetCard(0x3b) or c:IsRace(RACE_WARRIOR))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e6con(e,tp,eg,ep,ev,re,r)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
	and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e6tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e6fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.e6evt(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e6fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
