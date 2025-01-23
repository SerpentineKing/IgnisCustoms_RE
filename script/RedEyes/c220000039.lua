-- Black Dragon's Dominance
local s,id,o=GetID()
-- c220000039
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,{id,0})
	c:RegisterEffect(e0)
	-- Negate the effect of any card that would reduce the ATK of monsters you control.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	•
	This turn, each time a "Red-Eyes" monster(s) is Special Summoned from the GY to your field:
	Increase the ATK of all "Red-Eyes" monsters you currently control by the number of "Red-Eyes" monsters on the field x 400.
	•
	This turn, each time a monster(s) is Special Summoned from your opponent's GY to their field:
	Monsters your opponent controls lose 400 ATK for each "Red-Eyes" monster on the field.
	]]--
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetType(EFFECT_TYPE_QUICK_O)
	e2a:SetCode(EVENT_FREE_CHAIN)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetOperation(s.e2aevt)
	c:RegisterEffect(e2a)

	local e2b=e2a:Clone()
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetOperation(s.e2bevt)
	c:RegisterEffect(e2b)
end
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1tgt(e,c)
	return c:IsFaceup()
end
function s.e1val(e,te)
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
function s.e2aevt(e,tp)
	local e2a2=Effect.CreateEffect(c)
	e2a2:SetCategory(CATEGORY_ATKCHANGE)
	e2a2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2a2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a2:SetRange(LOCATION_SZONE)
	e2a2:SetCondition(s.e2acon)
	e2a2:SetOperation(s.e2a2evt)
	e2a2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+RESET_END)
	c:RegisterEffect(e2a2)
end
function s.e2afil1(c,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.e2acon(e,tp,eg)
	return eg:IsExists(s.e2afil1,1,nil,tp)
end
function s.e2afil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e2a2evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.e2afil2,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.GetMatchingGroupCount(s.e2afil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	local gs=g:GetFirst()
	for gs in aux.Next(g) do
		local e2a3=Effect.CreateEffect(c)
		e2a3:SetType(EFFECT_TYPE_SINGLE)
		e2a3:SetCode(EFFECT_UPDATE_ATTACK)
		e2a3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2a3:SetValue(400*ct)
		gs:RegisterEffect(e2a3)
	end
end
function s.e2bevt(e,tp)
	local e2b2=Effect.CreateEffect(c)
	e2b2:SetCategory(CATEGORY_ATKCHANGE)
	e2b2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2b2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2b2:SetRange(LOCATION_SZONE)
	e2b2:SetCondition(s.e2bcon)
	e2b2:SetOperation(s.e2b2evt)
	e2b2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+RESET_END)
	c:RegisterEffect(e2b2)
end
function s.e2bfil1(c,tp)
	return c:IsMonster()
	and c:IsPreviousLocation(LOCATION_GRAVE)
	and c:IsPreviousControler(1-tp)
end
function s.e2bcon(e,tp,eg)
	return eg:IsExists(s.e2bfil1,1,nil,tp)
end
function s.e2bfil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e2b2evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.GetMatchingGroupCount(s.e2bfil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	local gs=g:GetFirst()
	for gs in aux.Next(g) do
		local e2b3=Effect.CreateEffect(c)
		e2b3:SetType(EFFECT_TYPE_SINGLE)
		e2b3:SetCode(EFFECT_UPDATE_ATTACK)
		e2b3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2b3:SetValue(-400*ct)
		gs:RegisterEffect(e2b3)
	end
end
