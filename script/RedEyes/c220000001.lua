-- Red-Eyes Darkness Chaos Max Dragon
local s,id,o=GetID()
-- c220000001
function s.initial_effect(c)
	-- You can Ritual Summon this card with “Chaos Form” or “Red-Eyes Re-Transmigration”.
	c:EnableReviveLimit()
	-- Cannot be targeted by card effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Cannot be destroyed by card effects.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- If this card attacks a Defense Position monster, inflict piercing battle damage.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	--[[
	At the end of the Damage Step, if this card attacked a Defense Position monster:
	Inflict damage to your opponent equal to that monster's original ATK.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	If this card is sent from the field to the GY:
	You can Fusion Summon 1 Fusion Monster from your Extra Deck that mentions “Red-Eyes Black Dragon” as material,
	by sending materials listed on it from your Deck to the GY.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,0})
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
-- Mentions : "Chaos Form",“Red-Eyes Re-Transmigration”
s.listed_names={21082832,220000038,id}
-- Archetype : Red-Eyes, Chaos
s.listed_series={SET_RED_EYES,SET_CHAOS}
-- Helpers
function s.e4con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=Duel.GetAttackTarget()

	if not d then return false end
	
	local dmg=d:GetBaseAttack()
	e:SetLabel(dmg)
	
	return c==Duel.GetAttacker() and dmg>0 and (d:GetBattlePosition()&POS_DEFENSE)~=0
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
function s.e5con(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local fparams={handler=c,fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_REDEYES_B_DRAGON),matfilter=aux.FALSE,extrafil=s.efil,extratg=s.tfil}
	local fustg=Fusion.SummonEffTG(fparams)

	if chk==0 then
		return fustg(e,tp,eg,ep,ev,re,r,rp,0)
	end

	fustg(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.e5evt(e,tp)
	local fparams={handler=c,fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_REDEYES_B_DRAGON),matfilter=aux.FALSE,extrafil=s.efil,extratg=s.tfil}
	local fustg=Fusion.SummonEffTG(fparams)
	local fusop=Fusion.SummonEffOP(fparams)

	local b=fustg(e,tp,eg,ep,ev,re,r,rp,0)
	if b then
		fusop(e,tp,eg,ep,ev,re,r,rp,0)
	end
end
function s.efil(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.tfil(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_GRAVE)
end
