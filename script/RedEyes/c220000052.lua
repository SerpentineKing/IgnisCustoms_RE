-- Alligator's Blazing Sword Dragon
local s,id,o=GetID()
-- c220000052
function s.initial_effect(c)
	-- 1 Dragon monster + 1 Level 4 or lower "Red-Eyes" monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- This card can attack directly.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is Fusion Summoned:
	You can Special Summon 1 Level 4 or lower "Red-Eyes" monster, or 1 Level 1 Dragon monster, from your Deck,
	also, you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Fusion or Xyz Monsters.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is sent from the Monster Zone to the GY:
	You can target 1 WIND, DARK, or LIGHT monster your opponent controls;
	negate its effects until the end of this turn.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : N/A
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevelBelow(4)
end
function s.e2con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.e2fil(c,e,tp)
	return ((c:IsSetCard(SET_RED_EYES)
	and c:IsLevelBelow(4))
	or (c:IsRace(RACE_DRAGON)
	and c:IsLevel(1)))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.e2lim(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
	and not (c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ))
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)

		local e2b=Effect.CreateEffect(c)
		e2b:SetType(EFFECT_TYPE_FIELD)
		e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2b:SetTargetRange(1,0)
		e2b:SetTarget(s.e2lim)
		e2b:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2b,tp)
	end
end
function s.e3con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.e3fil(c)
	return c:IsFaceup()
	and c:IsType(TYPE_EFFECT)
	and not c:IsDisabled()
	and (c:IsAttribute(ATTRIBUTE_WIND) or c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT))
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(1-tp)
		and s.e3fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil,tp,0,LOCATION_MZONE,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	
	local tc=Duel.SelectTarget(tp,s.e3fil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,1-tp,LOCATION_MZONE)
end
function s.e3evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)

		local e3b1=Effect.CreateEffect(c)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_DISABLE)
		e3b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3b1)

		local e3b2=Effect.CreateEffect(c)
		e3b2:SetType(EFFECT_TYPE_SINGLE)
		e3b2:SetCode(EFFECT_DISABLE_EFFECT)
		e3b2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3b2:SetValue(RESET_TURN_SET)
		e3b2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3b2)
	end
end
