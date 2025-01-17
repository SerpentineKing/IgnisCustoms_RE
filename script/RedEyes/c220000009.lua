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
	-- If this card is the monster with the highest ATK on the field (even if it's tied), it can attack thrice per Battle Phase.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.e2con)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	-- Other monsters you control cannot declare an attack during the turn this card declares 2 or more attacks.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.e3tgt)
	c:RegisterEffect(e3)

	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(function(_,_,_,ep) Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end)
	-- Negate the effect of any card that would increase the ATK of a monster your opponent controls.
	-- TODO
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	--[[
	If this card is destroyed by card effect:
	Destroy 1 Spell/Trap your opponent controls.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
	--[[
	If this card is destroyed by battle:
	Equip this card to the monster that destroyed it.

	At the start of the Damage Step, if a monster equipped with this card by this effect battles:
	Destroy it, and if you do, inflict 2400 damage to your opponent.
	]]--
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(s.e6con)
	e6:SetOperation(s.e6evt)
	c:RegisterEffect(e6)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e2fil(c,ec)
	return c==ec
end
function s.e2con(e)
	local c=e:GetHandler()
	local tp=c:GetControler()

	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	
	return g and g:IsExists(s.e2fil,1,nil,c)
	and c:GetAttackAnnouncedCount()==(Duel.GetFlagEffect(0,id)+Duel.GetFlagEffect(1,id))
end
function s.e3tgt(e,c)
	local ec=e:GetHandler()
	return c~=ec and ec:GetAttackAnnouncedCount()>1
end
function s.e5con(e,tp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
function s.e5fil(c)
	return c:IsSpellTrap()
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	local g=Duel.GetMatchingGroup(s.e5fil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e5evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e5fil,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		
		local sg=g:Select(tp,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.e6con(e,tp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
end
function s.e6evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	
	if c==tc then tc=Duel.GetAttackTarget() end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 or tc:IsFacedown() or not tc:IsRelateToBattle() then return end

	if Duel.Equip(tp,c,tc) then
		local e6b=Effect.CreateEffect(c)
		e6b:SetType(EFFECT_TYPE_SINGLE)
		e6b:SetCode(EFFECT_EQUIP_LIMIT)
		e6b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e6b:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e6b:SetLabelObject(tc)
		c:RegisterEffect(e6b)

		local e6c=Effect.CreateEffect(c)
		e6c:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e6c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e6c:SetCode(EVENT_BATTLE_START)
		e6c:SetRange(LOCATION_SZONE)
		e6c:SetCountLimit(1)
		e6c:SetCondition(s.e6ccon)
		e6c:SetOperation(s.e6cevt)
		e6c:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e6c)
	end
end
function s.e6ccon(e,tp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc=e:GetHandler():GetEquipTarget()

	return (a==tc or d==tc)
end
function s.e6cevt(e,tp)
	local tc=e:GetHandler():GetEquipTarget()
	if tc then
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,2400,REASON_EFFECT)
		end
	end
end
