-- Gilford the Legend of Blazing Red Lightning
local s,id,o=GetID()
-- c220000014
function s.initial_effect(c)
	--[[
	[HOPT]
	You can Special Summon this card (from your hand) by sending 3 other “Red-Eyes” monsters from your hand to the GY.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,{id,0})
	e1:SetValue(1)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	When Summoned this way:
	Destroy as many monsters your opponent controls as possible,
	and if you do, inflict 500 damage to your opponent for each monster destroyed by this effect.
	]]--
	-- FIX [Condition]
	local e1b=Effect.CreateEffect(c)
	e1b:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetCondition(s.e1bcon)
	e1b:SetTarget(s.e1btgt)
	e1b:SetOperation(s.e1bevt)
	c:RegisterEffect(e1b)
	--[[
	[HOPT]
	If this card battles, during damage calculation:
	This card gains ATK equal to half the ATK of the monster your opponent controls with the highest ATK (your choice, if tied).
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsMonster()
	and c:IsSetCard(SET_RED_EYES)
	and c:IsAbleToGraveAsCost()
end
function s.e1con(e,c)
	if c==nil then return true end

	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_HAND,0,e:GetHandler())

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and rg:GetCount()>2
	and aux.SelectUnselectGroup(rg,e,tp,3,3,nil,0)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_HAND,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)

	if g:GetCount()>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	
	if not g then return end

	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.e1bcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.e1btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end

	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0,nil)
end
function s.e1bevt(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)

	local atk=0
	if g:GetCount()>0 then
		atk=g:GetFirst():GetAttack()/2
	end

	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,atk)
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)

		if g:GetCount()>0 then
			local atk=g:GetFirst():GetAttack()/2

			if atk>0 then
				local e2b=Effect.CreateEffect(c)
				e2b:SetType(EFFECT_TYPE_SINGLE)
				e2b:SetCode(EFFECT_UPDATE_ATTACK)
				e2b:SetValue(atk)
				c:RegisterEffect(e2b)
			end
		end
	end
end
