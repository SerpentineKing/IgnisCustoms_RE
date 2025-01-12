-- Black Flame Swordsman with Eyes of Red
local s,id,o=GetID()
-- c220000021
function s.initial_effect(c)
	--[[
	Once per turn, during the Battle Phase (Quick Effect):
	You can target 1 Dragon or Warrior monster you control;
	this card loses exactly 600 ATK,
	and if it does, that target gains 600 ATK.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card you control is destroyed by battle or card effect and sent to the GY:
	You can banish this card from your GY,
	then target 1 Dragon or Warrior monster in your GY, except “Black Flame Swordsman with Eyes of Red”;
	Special Summon that target.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Mentions : "Flame Swordsman"
s.listed_names={CARD_FLAME_SWORDSMAN,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES,0xfe2}
-- Helpers
function s.e1con(e)
	return Duel.IsBattlePhase()
	and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.e1fil(c)
	return (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR))
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and chkc:IsFaceup()
		and (chkc:IsRace(RACE_DRAGON) or chkc:IsRace(RACE_WARRIOR))
		and chkc~=c
	end
	if chk==0 then
		return c:IsAttackAbove(600)
		and Duel.IsExistingTarget(aux.FaceupFilter(s.e1fil),tp,LOCATION_MZONE,0,1,c)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FaceupFilter(s.e1fil),tp,LOCATION_MZONE,0,1,1,c)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsFacedown() and c:IsRelateToEffect(e) and not tc:IsFacedown() and tc:IsRelateToEffect(e) and c:UpdateAttack(-600)==-600 then 
		tc:UpdateAttack(600,nil,c)
	end
end
function s.e2con(e,tp)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) 
	and c:IsPreviousControler(tp)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e2fil(c,e,tp)
	return not c:IsCode(id)
	and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e2fil(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.e2fil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.e2evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
