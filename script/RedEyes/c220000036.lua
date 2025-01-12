-- Spell Card "Riryoku"
local s,id,o=GetID()
-- c220000036
function s.initial_effect(c)
	--[[
	During the Battle Phase:
	Target 2 face-up monsters on the field;
	until the end of this turn, halve the ATK of 1 monster,
	and if you do, add that lost ATK to the other monster,
	also, your opponent cannot activate cards or effects for the rest of this Battle Phase.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
-- Helpers
function s.e1con(e,tp)
	local ph=Duel.GetCurrentPhase()
	return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,g:GetCount(),tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	
	if g:GetCount()==0 then return end

	local hc=g:GetFirst()
	if g:GetCount()>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		hc=g:Select(tp,1,1,nil):GetFirst()
	end
	g:RemoveCard(hc)
	
	local c=e:GetHandler()
	local atk=hc:GetAttack()
	
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1b:SetReset(RESETS_STANDARD_PHASE_END)
	e1b:SetValue(atk/2)
	hc:RegisterEffect(e1b)

	if not hc:IsImmuneToEffect(e1b) and g:GetCount()>0 then
		local e1b=Effect.CreateEffect(c)
		e1c:SetType(EFFECT_TYPE_SINGLE)
		e1c:SetCode(EFFECT_UPDATE_ATTACK)
		e1c:SetReset(RESETS_STANDARD_PHASE_END)
		e1c:SetValue(atk/2)
		g:GetFirst():RegisterEffect(e1c)
	end

	local e1d=Effect.CreateEffect(c)
	e1d:SetType(EFFECT_TYPE_FIELD)
	e1d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1d:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1d:SetTargetRange(0,1)
	e1d:SetValue(1)
	e1d:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_BATTLE,0,1)
	Duel.RegisterEffect(e1d,tp)
end
