-- Black Dragon’s Dominance
local s,id,o=GetID()
-- c220000039
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated: Activate this effect;
	Halve the ATK of all monsters your opponent controls during each Battle Phase this turn.
	Your opponent cannot activate cards or effect in response to this card’s activation.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	-- The first time each “Red-Eyes” monster you control would be destroyed by battle or card effect, it is not destroyed.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RED_EYES))
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	-- Negate the effect of any card that would reduce the ATK of monsters you control.
	-- TODO
end
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1lim(e,ep,tp)
	return tp==ep
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetChainLimit(s.e1lim)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1b:SetTargetRange(0,LOCATION_MZONE)
	e1b:SetCondition(function() return Duel.IsBattlePhase() end)
	e1b:SetValue(s.e1val)
	e1b:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1b,tp)
end
function s.e1val(e,re)
	return e:GetHandler():GetAttack()/2
end
function s.e2val(e,re,r)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
