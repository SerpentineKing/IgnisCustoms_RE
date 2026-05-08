-- Red-Eyes Black Chaos MAX Dragon
local s,id,o=GetID()
-- c220000001
function s.initial_effect(c)
	-- You can Ritual Summon this card with "Chaos Form".
	c:EnableReviveLimit()
	-- This card cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Your opponent's monsters cannot target monsters for attacks, except this one.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.e2lim)
	c:RegisterEffect(e2)
	--[[
	At the end of the Damage Step, if this card battled an opponent's monster:
	Inflict damage to your opponent equal to that opponent's monster's original ATK,
	and if you do, destroy that monster.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[H1PT]
	If this card is sent to the GY by a card effect (except during the Damage Step):
	You can Fusion Summon 1 Fusion Monster from your Extra Deck
	that mentions a "Chaos" or "Black Luster Soldier" Ritual Monster as material,
	by using monsters from your hand and/or field as material.
	If your opponent controls a monster, you can also use 1 non-Effect Monster in your Deck/Extra Deck as material.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,0})
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
local CARD_CHAOS_FORM = 21082832
-- Mentions : "Chaos Form","Red-Eyes Black Dragon"
s.listed_names={CARD_CHAOS_FORM,CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes, Chaos
s.listed_series={SET_RED_EYES,SET_CHAOS}
-- Helpers
function s.e2lim(e,c)
	return c~=e:GetHandler()
end
function s.e3con(e,tp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()

	if not tc then return false end
	
	if tc:IsRelateToBattle() then
		return tc:IsControler(1-tp)
	else
		return tc:IsPreviousControler(1-tp)
	end
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then return true end

	local tc=c:GetBattleTarget()

	local dmg=tc:GetBaseAttack()
	if tc:IsRelateToBattle() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	else
		e:SetLabel(dmg)
	end

	e:SetLabelObject(tc)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
function s.e3evt(e,tp,eg,ep,ev,re,r,rp)
	local dmg=0
	local tc=e:GetLabelObject()
	local battle_relation=tc:IsRelateToBattle()

	if battle_relation and tc:IsFaceup() and tc:IsControler(1-tp) then
		dmg=tc:GetBaseAttack()
	elseif not battle_relation then
		dmg=e:GetLabel()
	end
	if Duel.Damage(1-tp,dmg,REASON_EFFECT)>0 and battle_relation then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.e4con(e)
	local c=e:GetHandler()

	return c:IsReason(REASON_EFFECT)
	and Duel.GetCurrentPhase()~=PHASE_DAMAGE
end
function s.e4sfil(c)
	local CARD_DRAGON_MASTER_MAGIA = 12381100
	local CARD_MASTER_OF_CHAOS = 85059922

	--[[
	return (c:IsSetCard(SET_CHAOS) or c:IsSetCard(SET_BLACK_LUSTER_SOLDIER) or c:IsSetCard(SET_NUMBER_C))
	and c:IsRitualMonster()
	]]--

	return (c:IsCode(CARD_DRAGON_MASTER_MAGIA) or c:IsCode(CARD_MASTER_OF_CHAOS))
end
function s.e4mxfil(c,e,tp)
	local sc=e:GetHandler()

	return c:IsNonEffectMonster()
	and c:IsCanBeFusionMaterial(sc)
	and c:IsAbleToGrave()
end
function s.e1sxfil(tp,sg,sc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=1
end
function s.e4xfil(e,tp,mg,sumtype)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
		return Duel.GetMatchingGroup(s.e4mxfil,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp),s.e1sxfil
	end
	return nil
end
function s.e4xtgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end 
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local fparams={handler=c,fusfilter=s.e4sfil,extrafil=s.e4xfil,extratg=s.e4xtgt}
	local fustg=Fusion.SummonEffTG(fparams)

	if chk==0 then
		return fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	end

	fustg(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.e4evt(e,tp)
	local fparams={handler=c,fusfilter=s.e4sfil,extrafil=s.e4xfil,extratg=s.e4xtgt}
	local fustg=Fusion.SummonEffTG(fparams)
	local fusop=Fusion.SummonEffOP(fparams)

	local b=fustg(e,tp,eg,ep,ev,re,r,rp,0)
	if b then
		fusop(e,tp,eg,ep,ev,re,r,rp,0)
	end
end
