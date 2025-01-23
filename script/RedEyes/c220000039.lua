-- Black Dragon's Dominance
local s,id,o=GetID()
-- c220000039
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	-- During your opponent's Battle Phase, halve the ATK of all monsters your opponent controls.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.e1con)
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	-- Negate the effect of any card that would reduce the ATK of monsters you control.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.e2tgt)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	•
	This turn, each time a "Red-Eyes" monster(s) is Special Summoned from the GY to your field:
	Increase the ATK of all "Red-Eyes" monsters you currently control by the number of "Red-Eyes" monsters on the field x 400.
	•
	This turn, each time a monster(s) is Special Summoned from your opponent's GY to their field:
	Monsters your opponent controls lose 400 ATK for each "Red-Eyes" monster on the field.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,0))
	e3a:SetType(EFFECT_TYPE_IGNITION)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetCountLimit(1,{id,1})
	e3a:SetOperation(s.e3aevt)
	c:RegisterEffect(e3a)

	local e3b=e3a:Clone()
	e3b:SetDescription(aux.Stringid(id,1))
	e3b:SetOperation(s.e3bevt)
	c:RegisterEffect(e3b)
end
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1con(e,tp)
	return Duel.IsBattlePhase()
	and Duel.GetTurnPlayer()~=tp
end
function s.e1val(e,c)
	return c:GetAttack()/2
end
function s.e2tgt(e,c)
	return c:IsFaceup()
end
function s.e2val(e,te)
	local res=false

	-- TODO : Fix
	local tc=e:GetHandler()
	local v=te:GetValue()

	if te:GetCode()==EFFECT_UPDATE_ATTACK and v then
		if type(v)=="number" and v<0 then
			res=true
		end
	elseif te:GetCode()==EFFECT_SET_BASE_ATTACK and v then
		if type(v)=="number" and v<tc:GetBaseAttack() then
			res=true
		end
	elseif (te:GetCode()==EFFECT_SET_ATTACK or te:GetCode()==EFFECT_SET_ATTACK_FINAL) and v then
		if type(v)=="number" and v<tc:GetAttack() then
			res=true
		end
	end

	return res
end
function s.e3aevt(e,tp)
	local e3a2=Effect.CreateEffect(c)
	e3a2:SetCategory(CATEGORY_ATKCHANGE)
	e3a2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3a2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3a2:SetRange(LOCATION_SZONE)
	e3a2:SetCondition(s.e3acon)
	e3a2:SetOperation(s.e3a2evt)
	e3a2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+RESET_END)
	c:RegisterEffect(e3a2)
end
function s.e3afil1(c,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.e3acon(e,tp,eg)
	return eg:IsExists(s.e3afil1,1,nil,tp)
end
function s.e3afil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e3a2evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.e3afil2,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.GetMatchingGroupCount(s.e3afil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	local gs=g:GetFirst()
	for gs in aux.Next(g) do
		local e3a3=Effect.CreateEffect(c)
		e3a3:SetType(EFFECT_TYPE_SINGLE)
		e3a3:SetCode(EFFECT_UPDATE_ATTACK)
		e3a3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3a3:SetValue(400*ct)
		gs:RegisterEffect(e3a3)
	end
end
function s.e3bevt(e,tp)
	local e3b2=Effect.CreateEffect(c)
	e3b2:SetCategory(CATEGORY_ATKCHANGE)
	e3b2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3b2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3b2:SetRange(LOCATION_SZONE)
	e3b2:SetCondition(s.e3bcon)
	e3b2:SetOperation(s.e3b2evt)
	e3b2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+RESET_END)
	c:RegisterEffect(e3b2)
end
function s.e3bfil1(c,tp)
	return c:IsMonster()
	and c:IsPreviousLocation(LOCATION_GRAVE)
	and c:IsPreviousControler(1-tp)
end
function s.e3bcon(e,tp,eg)
	return eg:IsExists(s.e3bfil1,1,nil,tp)
end
function s.e3bfil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e3b2evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.GetMatchingGroupCount(s.e3bfil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	local gs=g:GetFirst()
	for gs in aux.Next(g) do
		local e3b3=Effect.CreateEffect(c)
		e3b3:SetType(EFFECT_TYPE_SINGLE)
		e3b3:SetCode(EFFECT_UPDATE_ATTACK)
		e3b3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3b3:SetValue(-400*ct)
		gs:RegisterEffect(e3b3)
	end
end
