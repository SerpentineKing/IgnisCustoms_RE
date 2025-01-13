-- Warriors of the Red-Eyes
local s,id,o=GetID()
-- c220000033
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can add 1 Level 4 or lower Warrior monster from your Deck or GY to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If a Warrior monster(s) you control is destroyed by battle or card effect: You can banish this card from your GY;
	Special Summon 1 “Red-Eyes” or Warrior monster from your Deck or banishment.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	•
	When an attack is declared involving your Dragon monster:
	You can Special Summon 1 Level 4 or lower Warrior monster from your hand or GY.
	•
	When an attack is declared involving your Warrior monster:
	You can Special Summon 1 Level 7 or lower “Red-Eyes” monster from your hand or GY in face-up Defense Position,
	but its effects are negated, also it cannot attack this turn.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3a:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetCondition(s.e3acon)
	e3a:SetTarget(s.e3atgt)
	e3a:SetOperation(s.e3aevt)
	c:RegisterEffect(e3a)

	local e3b=Effect.CreateEffect(c)
	e3b:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3b:SetRange(LOCATION_SZONE)
	e3b:SetCountLimit(1,{id,2})
	e3b:SetCondition(s.e3bcon)
	e3b:SetTarget(s.e3btgt)
	e3b:SetOperation(s.e3bevt)
	c:RegisterEffect(e3b)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsLevelBelow(4)
	and c:IsRace(RACE_WARRIOR)
	and c:IsAbleToHand()
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.e2fil1(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
	and c:IsPreviousLocation(LOCATION_MZONE)
	and c:IsPreviousControler(tp)
	and c:IsRace(RACE_WARRIOR)
end
function s.e2fil2(c,e,tp)
	return (c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_WARRIOR))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp)
		and eg:IsExists(s.e2fil1,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e2fil2,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e3acon(e,tp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then
		tc=Duel.GetAttackTarget()
	end
	
	return tc
	and tc:IsFaceup()
	and tc:IsControler(tp)
	and tc:IsRace(RACE_DRAGON)
end
function s.e3afil(c,e,tp)
	return c:IsLevelBelow(4)
	and c:IsRace(RACE_WARRIOR)
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
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3afil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e3bcon(e,tp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then
		tc=Duel.GetAttackTarget()
	end
	
	return tc
	and tc:IsFaceup()
	and tc:IsControler(tp)
	and tc:IsRace(RACE_WARRIOR)
end
function s.e3bfil(c,e,tp)
	return c:IsLevelBelow(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.e3btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3bfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.e3bevt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	local g=Duel.SelectMatchingCard(tp,s.e3bfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local c=e:GetHandler()
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local tc=g:GetFirst()

		local e3b1=Effect.CreateEffect(c)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_DISABLE)
		e3b1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3b1)

		local e3b2=Effect.CreateEffect(c)
		e3b2:SetType(EFFECT_TYPE_SINGLE)
		e3b2:SetCode(EFFECT_DISABLE_EFFECT)
		e3b2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3b2)

		local e3b3=Effect.CreateEffect(c)
		e3b3:SetDescription(3206)
		e3b3:SetType(EFFECT_TYPE_SINGLE)
		e3b3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3b3:SetCode(EFFECT_CANNOT_ATTACK)
		e3b3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3b3)
	end
end
