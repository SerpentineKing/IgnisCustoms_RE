-- Cerise in Ebony
local s,id,o=GetID()
-- c220000028
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[
	[HOPT]
	At the start of the Battle Phase:
	You can activate this effect; this turn, apply 1 of the following effects,
	or if you control a “Red-Eyes” monster, you can apply both effects.
	•
	Once per turn, if your Level 7 or higher “Red-Eyes” monster destroys an opponent’s monster by battle:
	It can make a second attack during this Battle Phase.
	•
	Your opponent cannot target a “Red-Eyes” monster you control for attack, unless they banish the top card of their Deck.
	]]--
	-- TODO : [E2, RE]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During your Main Phase, if this card is in your GY, except the turn it was sent there: You can banish this card;
	add 1 Spell/Trap that has “Red-Eyes” in its text from your GY or banishment to your hand, except “Cerise in Ebony”.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(aux.exccon)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e1evt(e,tp)
	local op=0
	if Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_MZONE,0,1,nil) then
		op=3
	else
		op=Duel.SelectEffect(tp,
			{aux.TRUE,aux.Stringid(id,1)},
			{aux.TRUE,aux.Stringid(id,2)})
	end

	local c=e:GetHandler()
	if op==1 or op==3 then
		local e1b=Effect.CreateEffect(c)
		e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1b:SetCode(EVENT_BATTLE_DESTROYING)
		e1b:SetCountLimit(1)
		e1b:SetRange(LOCATION_SZONE)
		e1b:SetCondition(s.e1bcon)
		e1b:SetOperation(s.e1bevt)
		e1b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1b)
	end
	if op==2 or op==3 then
		local e1c=Effect.CreateEffect(c)
		e1c:SetType(EFFECT_TYPE_FIELD)
		e1c:SetCode(EFFECT_ATTACK_COST)
		e1c:SetRange(LOCATION_SZONE)
		e1c:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1c:SetTargetRange(0,1)
		e1c:SetCost(s.e1ccst)
		e1c:SetOperation(s.e1cevt)
		e1c:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1c)

		local e1d=Effect.CreateEffect(c)
		e1d:SetType(EFFECT_TYPE_FIELD)
		e1d:SetCode(id)
		e1d:SetRange(LOCATION_SZONE)
		e1d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1d:SetTargetRange(0,1)
		e1c:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1d)
	end
end
function s.e1bfil(c,tp)
	return c:IsStatus(STATUS_OPPO_BATTLE)
	and c:IsRelateToBattle()
	and c:IsSetCard(SET_RED_EYES)
	and c:IsLevelAbove(7)
	and c:IsControler(tp)
	and c:CanChainAttack()
end
function s.e1bcon(e,tp,eg)
	local c=e:GetHandler()
	if eg:IsExists(s.e1bfil,1,nil,tp) then
		return true
	end
	return false
end
function s.e1bevt(e,tp)
	Duel.ChainAttack()
end
function s.e1ccst(e,c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.IsPlayerCanDiscardDeckAsCost(tp,ct)
end
function s.e1cevt(e,tp)
	if Duel.IsAttackCostPaid()~=2 and e:GetHandler():IsLocation(LOCATION_SZONE) then
		local g=Duel.GetDecktopGroup(tp,1)
		
		if g:GetCount()==0 then return end
		
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		Duel.AttackCostPaid()
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
	and not c:IsCode(id)
	and c:IsSpellTrap()
	and c:IsAbleToHand()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
