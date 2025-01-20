-- Red-Eyes Shadow Eclipse Dragon
local s,id,o=GetID()
-- c220000015
function s.initial_effect(c)
	--[[
	[HOPT]
	You can reveal this card in your hand;
	shuffle 1 other card from your hand into the Deck,
	and if you do, Special Summon this card.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is Special Summoned:
	You can target 1 other face-up monster you control;
	equip 1 Equip Spell, or 1 Normal Trap that has an effect to equip itself to a monster, from your Deck or GY to that appropriate monster.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is destroyed by battle or an opponent's card effect:
	You can banish this card from your GY;
	take 1 card that has "Metalmorph" in its text in your GY or banishment, except this card,
	and either add it to your hand or shuffle it into the Deck.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[SOPT]
	Once per turn, if another monster you control is targeted for an attack:
	You can Tribute this card;
	end the Battle Phase,
	also, change the attacking monster's ATK to 0 until the start of your opponent’s next turn,
	and if you do, inflict 500 damage to your opponent.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.e4cst)
	e4:SetCondition(s.e4con)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsPublic()
	end
end
function s.e1fil(c)
	return c:IsAbleToDeck()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND,0,1,c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.e1evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e2fil(c,ec)
	-- TODO : Set Equip Card Traps
	return c:IsEquipSpell()
	and c:CheckEquipTarget(ec)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsFaceup()
		and chkc:IsControler(tp)
		and chkc~=c
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,chkc)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.e2evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsFaceup() and tc:IsMonster() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)

		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e2fil),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc)
		local ec=g:GetFirst()
		if ec then
			Duel.Equip(tp,ec,tc)
		end
	end
end
function s.e3con(e,tp)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
function s.e3fil(c)
	-- Lists "Metalmorph"
	return (c:ListsCode(CARD_MAX_METALMORPH)
	or c:ListsCode(68540058)
	or c:IsSetCard(SET_METALMORPH)
	or c:IsCode(24311372))
	and (c:IsAbleToHand() or c:IsAbleToDeck())
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c)
	end

	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,c)
	if g:GetCount()>0 then
		local tc=g:GetFirst()

		local op=1
		if b1 and b2 then
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,3)},
				{b2,aux.Stringid(id,4)})
		elseif (not b1) and b2 then
			op=2
		end
		
		if op==1 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		elseif op==2 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReleasable()
	end

	Duel.Release(c,REASON_COST)
end
function s.e4con(e,tp,eg,ep,ev,re,r)
	local c=e:GetHandler()
	local bt=eg:GetFirst()

	return r~=REASON_REPLACE
	and c~=bt
	and bt:GetControler()==c:GetControler()
end
function s.e4evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	if not c:IsRelateToEffect(e) then return end
	
	local a=Duel.GetAttacker()

	if not a:IsImmuneToEffect(e) and a:GetAttack()>0 then
		local e4b=Effect.CreateEffect(c)
		e4b:SetCategory(CATEGORY_ATKCHANGE)
		e4b:SetType(EFFECT_TYPE_SINGLE)
		e4b:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4b:SetValue(0)
		e4b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OPPO_TURN,1)
		a:RegisterEffect(e4b)

		Duel.Damage(1-tp,500,REASON_EFFECT)
	end

	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
