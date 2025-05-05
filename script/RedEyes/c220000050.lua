-- Thousand Dragon, Breath of Time Magic
local s,id,o=GetID()
-- c220000050
function s.initial_effect(c)
	-- 1 "Time Wizard" monster + 1 Level 3 or 4 Dragon monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	--[[
	[HOPT]
	If this card is Fusion Summoned:
	You can make the ATK of all face-up monsters your opponent currently controls become their original ATK,
	then if you called the result of an effect that tosses a coin once correctly this turn, negate the effects of those monsters.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If a monster(s) you control is destroyed by card effect, while this card is in your GY (except during the Damage Step):
	You can Special Summon this card, but banish it when it leaves the field.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Archetype : N/A
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	-- "Time Wizard" monsters
	return (c:IsCode(71625222)
	or c:IsCode(26273196)
	or c:IsCode(220000024))
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON)
	and (c:IsLevel(3) or c:IsLevel(4))
end
function s.e1con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
end
function s.e1fil1(c)
	return c:IsFaceup()
	and (c:GetAttack()~=c:GetBaseAttack() or c:GetDefense()~=c:GetBaseDefense())
end
function s.e1fil2(c)
	return c:IsFaceup()
	and c:IsType(TYPE_EFFECT)
	and not c:IsDisabled()
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	local g1=Duel.GetMatchingGroup(s.e1fil1,tp,0,LOCATION_MZONE,nil)
	local tc1=g:GetFirst()
	for tc1 in aux.Next(g1) do
		if tc1:GetAttack()~=tc1:GetBaseAttack() then
			local e1b1=Effect.CreateEffect(c)
			e1b1:SetType(EFFECT_TYPE_SINGLE)
			e1b1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1b1:SetValue(tc1:GetBaseAttack())
			e1b1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc1:RegisterEffect(e1b1)
		end

		if tc1:GetDefense()~=tc1:GetBaseDefense() then
			local e1b2=Effect.CreateEffect(c)
			e1b2:SetType(EFFECT_TYPE_SINGLE)
			e1b2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e1b2:SetValue(tc1:GetBaseDefense())
			e1b2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc1:RegisterEffect(e1b2)
		end
	end

	local g2=Duel.GetMatchingGroup(s.e1fil2,tp,0,LOCATION_MZONE,nil)
	local tc2=g2:GetFirst()
	for tc2 in aux.Next(g2) do
		local e1c1=Effect.CreateEffect(c)
		e1c1:SetType(EFFECT_TYPE_SINGLE)
		e1c1:SetCode(EFFECT_DISABLE)
		e1c1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e1c1)

		local e1c2=Effect.CreateEffect(c)
		e1c2:SetType(EFFECT_TYPE_SINGLE)
		e1c2:SetCode(EFFECT_DISABLE_EFFECT)
		e1c2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e1c2)
	end
end
function s.e2fil(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE)
	and c:IsPreviousControler(tp)
	and c:IsReason(REASON_EFFECT)
end
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.e2fil,1,nil,tp)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			local e2b=Effect.CreateEffect(c)
			e2b:SetDescription(3300)
			e2b:SetType(EFFECT_TYPE_SINGLE)
			e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e2b:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e2b:SetValue(LOCATION_REMOVED)
			e2b:SetReset(RESET_EVENT+RESETS_REDIRECT)
			c:RegisterEffect(e2b,true)
		end
	end
end
