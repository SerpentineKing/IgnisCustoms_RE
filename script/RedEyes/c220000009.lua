-- Red-Eyes Alternative Supreme Dragon
local s,id,o=GetID()
-- c220000009
function s.initial_effect(c)
	-- 3 Level 7 monsters
	Xyz.AddProcedure(c,aux.TRUE,7,3)
	c:EnableReviveLimit()
	-- This card’s name becomes “Red-Eyes Black Dragon" while on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(CARD_REDEYES_B_DRAGON)
	c:RegisterEffect(e1)
	--[[
	If this card is the monster with the highest ATK on the field (even if tied), it can attack thrice per Battle Phase.
	Other monsters you control cannot declare an attack during the turn this card declares 2 or more attacks.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.e2con)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--[[
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2b:SetTarget(s.e2btgt)
	e2b:SetOperation(s.e2bevt)
	c:RegisterEffect(e2b)
	]]--
	-- Negate the effect of any card that would increase the ATK of a monster your opponent controls.	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.e3con)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e2fil(c,tp)
	return c:IsControler(tp)
	and c:IsFaceup()
	and c:IsCode(id)
end
function s.e2con(e)
	local c=e:GetHandler()
	local tp=c:GetControler()

	local ac1=Duel.GetActivityCount(tp,ACTIVITY_ATTACK)
	local ac2=c:GetAttackAnnouncedCount()
	local acf=true
	if ac1>0 and ac2<ac1 then
		acf=false
	end

	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	return g and g:IsExists(s.e2fil,1,nil,tp) and acf
end
function s.e2btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:GetAttackAnnouncedCount()==2
	end
end
function s.e2lim(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
function s.e2bevt(e,tp)
	local c=e:GetHandler()

	local e2c=Effect.CreateEffect(c)
	e2c:SetType(EFFECT_TYPE_FIELD)
	e2c:SetCode(EFFECT_CANNOT_ATTACK)
	e2c:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e2c:SetTargetRange(LOCATION_MZONE,0)
	e2c:SetTarget(s.e2lim)
	e2c:SetLabel(c:GetFieldID())
	e2c:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2c,tp)
end
function s.e3con(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasCategory(CATEGORY_ATKCHANGE)
	and re:GetValue()>0
	and re:GetTargetRange()[1]~=0
end
function s.e3evt(e,tp,eg,ep,ev)
	Duel.NegateEffect(ev)
end
