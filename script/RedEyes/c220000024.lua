-- Time Wizard with Eyes of Red
local s,id,o=GetID()
-- c220000024
function s.initial_effect(c)
	-- This card's name becomes "Time Wizard" while on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(71625222)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During your Main Phase: You can toss a coin and call it, then apply the appropriate effect.
	•
	If you call it right:
	Destroy as many cards your opponent controls as possible,
	and if you do, inflict damage equal to half the combined original ATK of all face-up monsters destroyed by this effect,
	and if you do that, Special Summon 1 "Red-Eyes" monster from your hand, Deck, or GY, except "Time Wizard with Eyes of Red".
	•
	If you call it wrong:
	Destroy as many monsters you control as possible,
	and if you do, take damage equal to half the combined ATK those destroyed monsters had on the field.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect: You can discard 1 card;
	add 1 Level 4 or lower "Red-Eyes" or Spellcaster monster from your Deck to your hand, except "Time Wizard with Eyes of Red".
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.e3cst)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Coin Toss
s.toss_coin=true
-- Helpers
function s.e2fil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	if Duel.CallCoin(tp) then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local dg=Duel.GetOperatedGroup()
			local sum=dg:Filter(Card.IsFaceup,nil):GetSum(Card.GetBaseAttack)
			
			if Duel.Damage(1-tp,sum/2,REASON_EFFECT) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
				local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
				if g:GetCount()>0 then
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	else
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local dg=Duel.GetOperatedGroup()
			local sum=dg:GetSum(Card.GetAttack)
			Duel.Damage(tp,sum/2,REASON_EFFECT)
		end
	end
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end

	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.e3con(e,tp,eg,ep,ev,re,r)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
	and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e3fil(c)
	return ((c:IsSetCard(SET_RED_EYES) and c:IsMonster()) or c:IsRace(RACE_SPELLCASTER))
	and c:IsLevelBelow(4)
	and not c:IsCode(id)
	and c:IsAbleToHand()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_DECK,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
