-- Rocket Warrior with Eyes of Red
local s,id,o=GetID()
-- c220000025
function s.initial_effect(c)
	--[[
	[HOPT]
	If you control no monsters:
	You can Special Summon this card and 1 Level 4 or lower “Red-Eyes” monster from your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During your Battle Phase (Quick Effect):
	You can target 1 other “Red-Eyes” monster you control; equip this card to it.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is sent to the GY while equipped to a monster:
	You can target 1 “Red-Eyes” monster you control; equip this card to it.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	A “Red-Eyes” monster equipped with this card gains the following effects.
	•
	This card gains 1500 ATK.
	•
	This card cannot be destroyed by battle or card effects during the Battle Phase.
	•
	If this card attacks a monster, after damage calculation:
	That attack target loses 1500 ATK until the end of this turn.
	]]--
	local e4a1=Effect.CreateEffect(c)
	e4a1:SetCategory(CATEGORY_ATKCHANGE)
	e4a1:SetType(EFFECT_TYPE_SINGLE)
	e4a1:SetCode(EFFECT_UPDATE_ATTACK)
	e4a1:SetValue(1500)

	local e4b1=Effect.CreateEffect(c)
	e4b1:SetType(EFFECT_TYPE_SINGLE)
	e4b1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4b1:SetCondition(s.e4bcon)
	e4b1:SetValue(1)

	local e4c1=Effect.CreateEffect(c)
	e4c1:SetType(EFFECT_TYPE_SINGLE)
	e4c1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4c1:SetCondition(s.e4ccon)
	e4c1:SetValue(1)

	local e4d1=Effect.CreateEffect(c)
	e4d1:SetCategory(CATEGORY_ATKCHANGE)
	e4d1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4d1:SetCode(EVENT_BATTLED)
	e4d1:SetCondition(s.e4dcon)
	e4d1:SetOperation(s.e4devt)

	local e4a2=Effect.CreateEffect(c)
	e4a2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4a2:SetRange(LOCATION_SZONE)
	e4a2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4a2:SetTarget(function(e,c) return e:GetHandler():GetEquipTarget()==c and c:IsSetCard(SET_RED_EYES) and c:IsMonster() end)
	e4a2:SetLabelObject(e4a1)
	c:RegisterEffect(e4a2)

	local e4b2=e4a2:Clone()
	e4b2:SetLabelObject(e4b1)
	c:RegisterEffect(e4b2)

	local e4c2=e4a2:Clone()
	e4c2:SetLabelObject(e4c1)
	c:RegisterEffect(e4c2)

	local e4d2=e4a2:Clone()
	e4d2:SetLabelObject(e4d1)
	c:RegisterEffect(e4d2)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1con(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.e1fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevelBelow(4)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND,0,1,c,e,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_HAND,0,1,1,c,e,tp)
	if g:GetCount()>0 then
		local sg=Group.CreateGroup()
		sg:AddCard(c)
		sg:AddCard(g:GetFirst())

		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e2con(e,tp)
	return Duel.GetCurrentPhase()==PHASE_BATTLE
	and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.e2fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsFaceup()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and chkc:IsFaceup()
		and chkc:IsSetCard(SET_RED_EYES)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.e2fil,tp,LOCATION_MZONE,0,1,c)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)

	Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then return end
	
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		return Duel.SendtoGrave(c,REASON_RULE)
	end
	
	if Duel.Equip(tp,c,tc) then
		local e2b=Effect.CreateEffect(c)
		e2b:SetType(EFFECT_TYPE_SINGLE)
		e2b:SetCode(EFFECT_EQUIP_LIMIT)
		e2b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2b:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e2b:SetLabelObject(tc)
		c:RegisterEffect(e2b)
	end
end
function s.e3con(e,tp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()==LOCATION_SZONE
	and not c:IsReason(REASON_LOST_TARGET)
end
function s.e3fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsFaceup()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.e3fil,tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)

	Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,0,0,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then return end
	
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		return Duel.SendtoGrave(c,REASON_RULE)
	end
	
	if Duel.Equip(tp,c,tc) then
		local e3b=Effect.CreateEffect(c)
		e3b:SetType(EFFECT_TYPE_SINGLE)
		e3b:SetCode(EFFECT_EQUIP_LIMIT)
		e3b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3b:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e3b:SetLabelObject(tc)
		c:RegisterEffect(e3b)
	end
end
function s.e4bcon(e,tp)
	return Duel.GetCurrentPhase()==PHASE_BATTLE
end
function s.e4ccon(e,tp)
	return Duel.GetCurrentPhase()==PHASE_BATTLE
end
function s.e4dcon(e,tp)
	local c=e:GetHandler()

	return c==Duel.GetAttacker()
	and Duel.GetAttackTarget()
end
function s.e4devt(e,tp)
	local c=e:GetHandler()
	local d=Duel.GetAttackTarget()

	if not d:IsRelateToBattle() or d:IsFacedown() then return end
	
	local e4d3=Effect.CreateEffect(c)
	e4d3:SetType(EFFECT_TYPE_SINGLE)
	e4d3:SetCode(EFFECT_UPDATE_ATTACK)
	e4d3:SetValue(-1500)
	e4d3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	d:RegisterEffect(e4d3)
end
