-- Red-Eyes Twin Inferno Dragon
local s,id,o=GetID()
-- c220000010
function s.initial_effect(c)
	-- 2 Level 7 monsters
	Xyz.AddProcedure(c,aux.TRUE,7,2)
	c:EnableReviveLimit()
	-- This card’s name becomes “Red-Eyes Black Dragon" while on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(CARD_REDEYES_B_DRAGON)
	c:RegisterEffect(e1)
	-- Cannot be destroyed by battle.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- This card can make up to 2 attacks on monsters during each Battle Phase.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(2)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e3)
	--[[
	At the end of the Damage Step, if this card attacks an opponent’s monster,
	but that opponent’s monster was not destroyed by battle:
	You can inflict damage to your opponent equal to that monster’s original ATK.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e4con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=c:GetBattleTarget()

	if not d then return false end

	local dmg=d:GetBaseAttack()
	e:SetLabel(dmg)

	return c==Duel.GetAttacker()
	and dmg>0
	and c:IsStatus(STATUS_OPPO_BATTLE)
	and d:IsOnField()
	and d:IsRelateToBattle()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local d=e:GetLabel()

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(d)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
end
function s.e4evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
