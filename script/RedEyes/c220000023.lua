-- Axe Raider with Eyes of Red
local s,id,o=GetID()
-- c220000023
function s.initial_effect(c)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can Special Summon 1 Level 4 or lower “Red-Eyes” or Warrior monster from your Deck or GY, except “Axe Raider with Eyes of Red”,
	also, you cannot Special Summon monsters from the Extra Deck for the rest of this turn,
	except “Red-Eyes” monsters or monsters that list a “Red-Eyes” monster as material.
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
	[HOPT]
	If this card is sent from the field to the GY:
	You can target 5 other cards that have “Red-Eyes” in their text in your GY and/or banishment;
	shuffle them into the Deck, and if you do, draw 2 cards.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c,e,tp)
	return (c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_WARRIOR))
	and c:IsLevelBelow(4)
	and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.e1lim(e,c)
	return (not (c:IsSetCard(SET_RED_EYES) or c:ListsArchetypeAsMaterial(SET_RED_EYES)))
	and c:IsLocation(LOCATION_EXTRA)
end
function s.e1evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end

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
	and c:IsAbleToDeck()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED))
		and chkc:IsControler(tp)
		and s.e2fil(chkc)
	end
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,5,5,c)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	
	local g=Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.e2evt(e,tp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end

	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
	end
	
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
