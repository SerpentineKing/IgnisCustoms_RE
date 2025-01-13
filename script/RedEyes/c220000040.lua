-- Black Dragon’s Bond
local s,id,o=GetID()
-- c220000040
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Your opponent cannot target “Red-Eyes” monsters you control with card effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RED_EYES))
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--[[
	If this face-up card is sent from the Spell & Trap Zone to the GY:
	Destroy 1 “Red-Eyes” monster you control,
	and if you do, take damage equal to its original ATK.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	You can activate 1 of these effects;
	•
	Special Summon 1 Level 7 or lower “Red-Eyes” monster from your hand or GY.
	•
	Set 1 Spell/Trap that has “Red-Eyes” in its text from your Deck with a different name from the cards you control and in your GY.
	•
	This turn, Gemini monsters on the field are treated as Effect Monsters, and gain their effects.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,0))
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3a:SetType(EFFECT_TYPE_QUICK_O)
	e3a:SetCode(EVENT_FREE_CHAIN)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetHintTiming(0,TIMING_END_PHASE)
	e3a:SetCountLimit(1,{id,0})
	e3a:SetTarget(s.e3atgt)
	e3a:SetOperation(s.e3aevt)
	c:RegisterEffect(e3a)

	local e3b=Effect.CreateEffect(c)
	e3b:SetDescription(aux.Stringid(id,1))
	e3b:SetType(EFFECT_TYPE_IGNITION)
	e3b:SetType(EFFECT_TYPE_QUICK_O)
	e3b:SetCode(EVENT_FREE_CHAIN)
	e3b:SetHintTiming(0,TIMING_END_PHASE)
	e3b:SetCountLimit(1,{id,0})
	e3b:SetTarget(s.e3btgt)
	e3b:SetOperation(s.e3bevt)
	c:RegisterEffect(e3b)

	local e3c=Effect.CreateEffect(c)
	e3c:SetDescription(aux.Stringid(id,2))
	e3c:SetType(EFFECT_TYPE_QUICK_O)
	e3c:SetCode(EVENT_FREE_CHAIN)
	e3c:SetRange(LOCATION_SZONE)
	e3c:SetHintTiming(0,TIMING_END_PHASE)
	e3c:SetCountLimit(1,{id,0})
	e3c:SetOperation(s.e3cevt)
	c:RegisterEffect(e3c)
end
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e2con(e,tp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE)
	and c:IsPreviousPosition(POS_FACEUP)
end
function s.e2fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			Duel.Damage(tp,tc:GetBaseAttack(),REASON_EFFECT)
		end
	end
end
function s.e3afil(c,e,tp)
	return c:IsLevelBelow(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3atgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3afil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.e3aevt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3afil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e3bfil(c,tp)
	return (c:IsSetCard(SET_RED_EYES)
	or c:IsSetCard(0xfe1)
	or c:IsCode(36262024)
	or c:IsCode(93969023)
	or c:IsCode(66574418)
	or c:IsCode(11901678)
	or c:IsCode(45349196)
	or c:IsCode(90660762)
	or c:IsCode(19025379)
	or c:IsCode(71408082)
	or c:IsCode(71408082)
	or c:IsCode(32566831)
	or c:IsCode(52684508)
	or c:IsCode(18803791))
	and c:IsSpellTrap()
	and c:IsSSetable()
	and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.e3btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3bfil,tp,LOCATION_DECK,0,1,nil,tp)
	end
end
function s.e3bevt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.e3bfil,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.SSet(tp,g)
	end
end
function s.e3cevt(e,tp)
	local e3c1=Effect.CreateEffect(c)
	e3c1:SetType(EFFECT_TYPE_FIELD)
	e3c1:SetCode(EFFECT_GEMINI_STATUS)
	e3c1:SetRange(LOCATION_SZONE)
	e3c1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3c1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_GEMINI))
	e3c1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e3c1)
end
