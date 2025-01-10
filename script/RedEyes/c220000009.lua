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
