-- Red-Eyes Black Full Potential Dragon
local s,id,o=GetID()
-- c220000011
function s.initial_effect(c)
	-- This card’s name becomes “Red-Eyes Black Dragon” while on the field or in the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(CARD_REDEYES_B_DRAGON)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If “Red-Eyes Sovereignty” is on the field: You can Special Summon this card from your hand.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is destroyed by card effect and sent to the GY or banishment,
	while another Level 5 or higher monster is on the field:
	You can Special Summon this card,
	then you can Set 1 Spell/Trap that has “Red-Eyes” in its text from your Deck.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "Red-Eyes Black Dragon","Red-Eyes Sovereignty"
s.listed_names={CARD_REDEYES_B_DRAGON,220000027,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e2con()
	return Duel.IsEnvironment(220000027)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e3con(e)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelAbove,5),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.e3fil(c)
	-- "Red-Eyes" Cards
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
end
function s.e3evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		
		local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_DECK,0,nil)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)

			local sg=g:Select(tp,1,1,nil)
			Duel.SSet(tp,sg)
		end
	end
end
