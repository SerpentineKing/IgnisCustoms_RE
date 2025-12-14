-- Alligator's Sword with Eyes of Red
local s,id,o=GetID()
-- c220000022
function s.initial_effect(c)
	--[[
	[HOPT]
	When an opponent's monster declares an attack, while your opponent controls 2 or more face-up monsters and you control a monster:
	You can discard this card, then target 1 face-up monster your opponent controls, except the attacking monster;
	take control of that face-up monster (until the end of the Battle Phase),
	and if you do, change the attack target to it and perform damage calculation.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can add 1 Spell/Trap that has "Red-Eyes" in its text from your Deck or GY to your hand.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1con(e,tp)
	return Duel.IsTurnPlayer(1-tp)
	and Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetCount()>1
	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
	end

	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.e1fil(c)
	return c:IsFaceup()
	and c:IsControlerCanBeChanged()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(1-tp)
		and s.e1fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1fil,tp,0,LOCATION_MZONE,1,a)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.e1fil,tp,0,LOCATION_MZONE,1,1,a)

	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.e1evt(e,tp)
	local tc=Duel.GetFirstTarget()
	local a=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetControl(tc,tp,PHASE_BATTLE,1)>0 then
		if a:CanAttack() and not a:IsImmuneToEffect(e) then
			Duel.CalculateDamage(a,tc)
		end
	end
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
	and c:IsSpellTrap()
	and c:IsAbleToHand()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
