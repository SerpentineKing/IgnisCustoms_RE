-- Red-Eyes Salamandra Dragon
local s,id,o=GetID()
-- c220000003
function s.initial_effect(c)
	-- "Red-Eyes Black Dragon" + 1 FIRE monster
	Fusion.AddProcMix(c,true,true,CARD_REDEYES_B_DRAGON,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE))
	c:EnableReviveLimit()
	--[[
	Must first be either Fusion Summoned, or Special Summoned from your Extra Deck
	by Tributing 1 "Red-Eyes Black Dragon" equipped with a Fusion Monster.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	-- This card can attack all monsters your opponent controls, once each.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--[[
	Once per turn, at the end of the Damage Step, if this card battled:
	You can target 1 Spell in your GY;
	either add it to your hand, or Set it to your field.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Red-Eyes Fusion
s.material_setcode=SET_RED_EYES
-- Helpers
function s.e1fil(c,tp,sc)
	return c:IsCode(CARD_REDEYES_B_DRAGON)
	and c:GetEquipGroup():IsExists(Card.IsOriginalType,1,nil,TYPE_FUSION)
	and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.e1con(e,c)
	if c==nil then return true end

	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.e1fil,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.e1fil,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.e1evt(e)
	local g=e:GetLabelObject()
	if not g then return end

	Duel.Release(g,REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end
function s.e3fil(c)
	return c:IsSpell()
	and (c:IsAbleToHand() or c:IsSSetable())
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e3fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil,tp,LOCATION_GRAVE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_GRAVE,0,1,1,nil)
	
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.e3evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end

	aux.ToHandOrElse(tc,tp,
		function()
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		end,
		function()
			Duel.SSet(tp,tc)
		end,
		aux.Stringid(id,3)
	)
end
