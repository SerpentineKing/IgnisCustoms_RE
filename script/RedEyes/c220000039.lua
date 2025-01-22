-- Black Dragon's Dominance
local s,id,o=GetID()
-- c220000039
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated: Activate this effect;
	Halve the ATK of all monsters your opponent controls during each Battle Phase this turn.
	Your opponent cannot activate cards or effect in response to this card's activation.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	-- The first time each "Red-Eyes" monster you control would be destroyed by battle or card effect, it is not destroyed.
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
	--[[
	Each time a "Red-Eyes" monster(s) is Special Summoned from your GY to your field:
	Increase the ATK of all "Red-Eyes" monsters you currently control by the number of "Red-Eyes" monsters on the field x 400.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.e4con)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	-- Monsters your opponent controls lose 400 ATK for each "Red-Eyes" monster on the field.
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(s.e5val)
	c:RegisterEffect(e5)
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
	e1b:SetValue(s.e1bval)
	e1b:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1b,tp)
end
function s.e1bval(e,re)
	return re:GetHandler():GetAttack()/2
end
function s.e2val(e,re,r)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
function s.e4fil(c,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsPreviousLocation(LOCATION_GRAVE)
	and c:IsPreviousControler(tp)
end
function s.e4con(e,tp,eg)
	local c=e:GetHandler()

	return not eg:IsContains(c)
	and eg:IsExists(s.e4fil,1,nil,tp)
end
function s.e4evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e5fil,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.e5fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	local gs=g:GetFirst()
	for gs in aux.Next(g) do
		local e1a1=Effect.CreateEffect(c)
		e1a1:SetType(EFFECT_TYPE_SINGLE)
		e1a1:SetCode(EFFECT_UPDATE_ATTACK)
		e1a1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1a1:SetValue(400*ct)
		gs:RegisterEffect(e1a1)
	end
end
function s.e5fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e5val(e)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetMatchingGroupCount(s.e5fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	return ct*-400
end
