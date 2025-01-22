-- Jinzo, Black Fullmetal Dragon Armored
local s,id,o=GetID()
-- c220000007
function s.initial_effect(c)
	--[[
	Cannot be Normal Summoned/Set.
	Must first be Special Summoned with "Max Metalmorph" that was activated by Tributing a Level 5 or higher Machine monster.
	]]--
	c:EnableReviveLimit()
	-- "Red-Eyes" monsters you control are unaffected by the effects of Trap Cards on your opponent’s field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	You can reveal this card in your hand;
	take 1 "Metalmorph" Trap, or 1 Trap that has "Red-Eyes" in its text, from your GY or banishment,
	and either add it to your hand or shuffle it into the Deck,
	and if you do, shuffle this card into the Deck.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	You can Tribute 1 Level 7 or higher "Red-Eyes" monster;
	destroy as many Traps your opponent controls as possible (if a card is Set, reveal it),
	and if you do, inflict 400 damage to your opponent for each card destroyed by this effect.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.e3cst)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	When your opponent activates a card or effect (Quick Effect):
	You can target 1 face-up monster your opponent controls;
	take control of it until the End Phase.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	If this card is sent from the field to the GY:
	You can banish this card from your GY;
	You can Special Summon 1 DARK Dragon or Machine monster from your hand, Deck, or GY, except "Jinzo, Black Fullmetal Dragon Armored".
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,5))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,3})
	e5:SetCost(aux.bfgcost)
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
-- Max Metalmorph
s.max_metalmorph_stats={5,RACE_MACHINE}
-- Mentions : "Max Metalmorph"
s.listed_names={CARD_MAX_METALMORPH,id}
-- Archetype : Jinzo, Red-Eyes
s.listed_series={SET_JINZO,SET_RED_EYES}
-- Helpers
function s.e1tgt(e,c)
	return c:IsSetCard(SET_RED_EYES)
end
function s.e1val(e,te)
	local tp=e:GetHandlerPlayer()

	return te:GetOwnerPlayer()==1-tp
	and te:IsTrapEffect()
	and te:GetActivateLocation(LOCATION_ONFIELD)
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsPublic()
	end
end
function s.e2fil(c)
	return ((c:IsSetCard(SET_RED_EYES)
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
	or c:IsSetCard(SET_METALMORPH))
	and c:IsTrap()
	and (c:IsAbleToHand() or c:IsAbleToDeck())
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		and c:IsAbleToDeck()
	end

	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)

	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()

		local b1=tc:IsAbleToHand()
		local b2=tc:IsAbleToDeck()

		if not (b1 or b2) then return end

		local op=1
		if b1 and b2 then
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,1)},
				{b2,aux.Stringid(id,2)})
		elseif (not b1) and b2 then
			op=2
		end
		
		local success=false
		if op==1 then
			if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
				success=true
			end
		elseif op==2 then
			if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
				success=true
			end
		end

		if success then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.e3fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevelAbove(7)
	and c:IsMonster()
	and (c:IsControler(tp) or c:IsFaceup())
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,s.e3fil,1,false,nil,nil)
	end
	local sg=Duel.SelectReleaseGroupCost(tp,s.e3fil,1,1,false,nil,nil)
	Duel.Release(sg,REASON_COST)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsTrap),tp,0,LOCATION_SZONE,1,nil)
		or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil)
	end
end
function s.e3evt(e,tp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	Duel.ConfirmCards(tp,g)

	local sg=g:Filter(Card.IsTrap,nil)
	
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 then
		Duel.Damage(1-tp,ct*400,REASON_EFFECT)
	end
end
function s.e4con(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
	and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(1-tp)
		and chkc:IsFaceup()
		and chkc:IsControlerCanBeChanged()
	end
	if chk==0 then
		return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.e4evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
function s.e5con(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e5fil(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
	and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_MACHINE))
	and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e5fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.e5evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e5fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
