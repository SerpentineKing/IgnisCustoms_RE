-- Black Flame Swordsman with Eyes of Red
local s,id,o=GetID()
-- c220000021
function s.initial_effect(c)
	-- If you control no monsters, you can Normal Summon this card without Tributing.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	-- Gains 700 ATK for each Equip Card equipped to it.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can target 1 other "Red-Eyes" monster you control;
	equip it to this card.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_EQUIP)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3a:SetCountLimit(1,{id,0})
	e3a:SetTarget(s.e3tgt)
	e3a:SetOperation(s.e3evt)
	c:RegisterEffect(e3a)

	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)
	--[[
	[HOPT]
	When this attacking card destroys an opponent's monster by battle and sends it to the GY:
	You can equip the destroyed monster to this card.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	If this card you control is destroyed by battle or card effect and sent to the GY:
	You can banish this card from your GY,
	then target 1 FIRE Warrior monster in your GY;
	Special Summon that target.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,2})
	e5:SetCost(aux.bfgcost)
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES,0xfe2}
-- Helpers
function s.e1con(e,c,minc)
	if c==nil then return true end
	
	return minc==0
	and c:GetLevel()>4
	and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
	and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
end
function s.e2val(e,c)
	return c:GetEquipCount()*700
end
function s.e3fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsFaceup()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsSetCard(SET_RED_EYES)
		and chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and chkc:IsFaceup()
		and chkc~=c
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil,tp,LOCATION_MZONE,0,1,c)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_MZONE,0,1,1,c)

	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.e3lim(e,c)
	return c==e:GetLabelObject()
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c,true) then
		local e3c=Effect.CreateEffect(c)
		e3c:SetType(EFFECT_TYPE_SINGLE)
		e3c:SetCode(EFFECT_EQUIP_LIMIT)
		e3c:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3c:SetValue(s.e3lim)
		e3c:SetLabelObject(c)
		tc:RegisterEffect(e3c)
	end
end
function s.e4con(e,tp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()

	return c==Duel.GetAttacker()
	and c:IsRelateToBattle()
	and c:IsStatus(STATUS_OPPO_BATTLE)
	and bc:IsLocation(LOCATION_GRAVE)
	and bc:IsMonster()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	local tc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.e4lim(e,c)
	return c==e:GetLabelObject()
end
function s.e4evt(e,tp)
	local c=e:GetHandler()
	
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c,true) then
		local e4b=Effect.CreateEffect(c)
		e4b:SetType(EFFECT_TYPE_SINGLE)
		e4b:SetCode(EFFECT_EQUIP_LIMIT)
		e4b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4b:SetValue(s.e4lim)
		e4b:SetLabelObject(c)
		tc:RegisterEffect(e4b)
	end
end
function s.e5con(e,tp)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) 
	and c:IsPreviousControler(tp)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e5fil(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE)
	and c:IsRace(RACE_WARRIOR)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e2fil(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.e5fil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectTarget(tp,s.e5fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.e5evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
