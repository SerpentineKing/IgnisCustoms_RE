-- Reinforcing Metalmorph
local s,id,o=GetID()
-- c220000057
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	Special Summon 1 Level 7 DARK Normal Monster from your hand or Deck in face-up Defense Position,
	then you can equip this card to it with the following effects.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE+TIMING_MAIN_END+TIMING_BATTLE_START+TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this Set card is sent from the field to the GY:
	You can Set this card.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
local CARD_METALMORPH = 68540058
-- Mentions : "Metalmorph","Max Metalmorph"
s.listed_names={CARD_METALMORPH,CARD_MAX_METALMORPH,id}
-- Archetype : Metalmorph
s.listed_series={SET_METALMORPH}
-- Helpers
function s.e1fil(c,e,tp)
	return c:IsLevel(7)
	and c:IsAttribute(ATTRIBUTE_DARK)
	and c:IsType(TYPE_NORMAL)
	and c:IsMonster()
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local tc=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		tc:CompleteProcedure()
		
		if not (c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
		c:CancelToGrave(true)
		
		Duel.BreakEffect()
		
		if not tc:EquipByEffectAndLimitRegister(e,tp,c,nil,true) then return end
		
		local e1b0=Effect.CreateEffect(c)
		e1b0:SetType(EFFECT_TYPE_SINGLE)
		e1b0:SetCode(EFFECT_EQUIP_LIMIT)
		e1b0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1b0:SetValue(function(e,c) return c==tc end)
		e1b0:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1b0)
		--[[
		This card's name becomes "Metalmorph" while in the Spell & Trap Zone.
		]]--
		local e1b1=Effect.CreateEffect(c)
		e1b1:SetType(EFFECT_TYPE_SINGLE)
		e1b1:SetCode(EFFECT_CHANGE_CODE)
		e1b1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1b1:SetRange(LOCATION_SZONE)
		e1b1:SetValue(CARD_METALMORPH)
		c:RegisterEffect(e1b1)
		--[[
		[SOPT]
		You can reveal any number of Machine monsters in your hand
		that cannot be Normal Summoned/Set and mention either "Metalmorph" or "Max Metalmorph",
		and place them on the bottom of your Deck in any order,
		then draw the same number of cards +1.
		]]--
		local e1b2=Effect.CreateEffect(c)
		e1b2:SetDescription(aux.Stringid(id,2))
		e1b2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		e1b2:SetType(EFFECT_TYPE_IGNITION)
		e1b2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1b2:SetRange(LOCATION_SZONE)
		e1b2:SetCountLimit(1)
		e1b2:SetTarget(s.e1b2tgt)
		e1b2:SetOperation(s.e1b2evt)
		c:RegisterEffect(e1b2)
	end
end
function s.e1b2fil(c)
	return not c:IsPublic()
	and c:IsRace(RACE_MACHINE)
	and c:IsMonster()
	and not c:IsSummonableCard()
	and (c:ListsCode(CARD_METALMORPH) or c:ListsCode(CARD_MAX_METALMORPH))
	and c:IsAbleToDeck()
end
function s.e1b2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(s.e1b2fil,tp,LOCATION_HAND,0,1,nil)
	end
	
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.e1b2evt(e,tp)
	local c=e:GetHandler()
	
	if not c:IsRelateToEffect(e) then return end

	local sp=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)

	local max=Duel.GetMatchingGroupCount(s.e1b2fil,sp,LOCATION_HAND,0,nil)
	if max==0 then return end

	Duel.Hint(HINT_SELECTMSG,sp,HINTMSG_TODECK)
	
	local g=Duel.SelectMatchingCard(sp,s.e1b2fil,sp,LOCATION_HAND,0,1,max,nil)
	if g:GetCount()>0 then
		Duel.ConfirmCards(1-sp,g)

		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		if ct>0 then
			if ct>1 then
				Duel.SortDeckbottom(sp,sp,ct)
			end

			Duel.BreakEffect()
			
			Duel.Draw(sp,ct,REASON_EFFECT)
		end
	end
end
function s.e2con(e,tp)
	local c=e:GetHandler()

	return c:IsPreviousPosition(POS_FACEDOWN)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsSSetable()
	end

	Duel.SetOperationInfo(0,CATEGORY_SET,c,1,tp,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end
