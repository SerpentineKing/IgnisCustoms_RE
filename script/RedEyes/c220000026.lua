-- Landstar Swordsman with Eyes of Red
local s,id,o=GetID()
-- c220000026
function s.initial_effect(c)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can Special Summon 1 Level 4 "Red-Eyes" or Warrior monster from your Deck,
	also, you cannot Special Summon monsters from the Extra Deck for the rest of this turn,
	except "Red-Eyes" monsters or monsters that list a "Red-Eyes" monster as material.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)

	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--[[
	[SOPT]
	Once per turn, when your monster is targeted for an attack:
	You can send 1 "Red-Eyes" monster from your hand or Deck to the GY, then roll a six-sided die.
	Until the end of this turn, all monsters you currently control gain ATK/DEF equal to the result x 200,
	and all monsters your opponent controls lose ATK/DEF equal to the result x 200.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Roll Dice
s.roll_dice=true
-- Helpers
function s.e1fil(c,e,tp)
	return (c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_WARRIOR))
	and c:IsLevel(4)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.e1lim(e,c)
	return (not (c:IsSetCard(SET_RED_EYES) or c:ListsArchetypeAsMaterial(SET_RED_EYES)))
	and c:IsLocation(LOCATION_EXTRA)
end
function s.e1evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end

	local c=e:GetHandler()
	
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetDescription(aux.Stringid(id,1))
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.e1lim)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
end
function s.e2fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local tc=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		Duel.BreakEffect()

		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		
		if g1:GetCount()==0 or g2:GetCount()==0 then return end

		local val=Duel.TossDice(tp,1)*200
		for tc in g1:Iter() do
			local e2b1=Effect.CreateEffect(c)
			e2b1:SetType(EFFECT_TYPE_SINGLE)
			e2b1:SetCode(EFFECT_UPDATE_ATTACK)
			e2b1:SetValue(val)
			e2b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2b1)

			local e2b2=e2b1:Clone()
			e2b2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2b2)
		end

		for tc in g2:Iter() do
			local e2b3=Effect.CreateEffect(c)
			e2b3:SetType(EFFECT_TYPE_SINGLE)
			e2b3:SetCode(EFFECT_UPDATE_ATTACK)
			e2b3:SetValue(-val)
			e2b3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2b3)

			local e2b4=e2b3:Clone()
			e2b4:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2b4)
		end
	end
end
