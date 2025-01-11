-- Red-Eyes Sovereignty
local s,id,o=GetID()
-- c220000027
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Cannot be destroyed by monster effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	-- Your opponent cannot activate cards or effects in response to the activation of your “Red-Eyes Fusion”.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	During your Main Phase:
	You can add 1 card that has “Red-Eyes” in its text from your Deck to your hand, except “Red-Eyes Sovereignty”.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	If your opponent Special Summons a monster(s) (except during the Damage Step):
	You can Special Summon 1 “Red-Eyes” monster from your hand, Deck, or GY.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	If this card is sent from the field to the GY: You can banish this card from your GY;
	show any number of “Red-Eyes Black Dragon” in your hand, GY, banishment, and/or face-up field to your opponent,
	then banish that many cards your opponent controls.
	]]--
	-- FIX [Reveal]
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
-- Mentions : "Red-Eyes Black Dragon","Red-Eyes Fusion"
s.listed_names={CARD_REDEYES_B_DRAGON,6172122,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1val(_,re)
	return re:IsMonsterEffect()
end
function s.e2lim(e,rp,tp)
	return tp==rp
end
function s.e2evt(e,tp,eg,ep,ev,re)
	if re:GetHandler():IsCode(6172122) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(s.e2lim)
	end
end
function s.e3fil(c)
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
function s.e4fil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e4con(e,tp,eg)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.e4evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e4fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e5fil(c)
	return c:IsCode(CARD_REDEYES_B_DRAGON)
	and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end
function s.e5con(sg,e,tp,mg)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=sg:GetCount()
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e5fil,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
	end

	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.e5vt(e,tp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)==0 then return end

	local showg=Duel.GetMatchingGroup(s.e5fil,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	
	if showg:GetCount()==0 then return end
	
	local g=aux.SelectUnselectGroup(showg,e,tp,1,13,s.e5con,1,tp,HINTMSG_CONFIRM)
	local ct=g:GetCount()
	
	if ct==0 then return end
	
	local confirmg,hintg=g:Split(Card.IsLocation,nil,LOCATION_HAND)
	
	if confirmg:GetCount()>0 then
		Duel.ConfirmCards(1-tp,confirmg)
		Duel.ShuffleHand(tp)
	end
	if hintg:GetCount()>0 then
		Duel.HintSelection(hintg)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local remg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	if remg:GetCount()>0 then
		Duel.HintSelection(remg)
		
		Duel.BreakEffect()

		Duel.Remove(remg,REASON_EFFECT)
	end
end
