-- Megacyber with Eyes of Red
local s,id,o=GetID()
-- c220000021
function s.initial_effect(c)
	--[[
	[H1PT]
	If you control no monsters, you can Special Summon this card (from your hand).
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	If this card is Special Summoned, and your opponent controls more monsters than you do:
	You can Special Summon Level 7 or lower "Red-Eyes" monsters with different names from your hand or GY,
	up to the difference.
	You cannot Special Summon monsters from the Extra Deck the turn you activate this effect,
	except Fusion or Xyz Monsters.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.e2xfil)
	--[[
	[H1PT]
	If this card is sent to the GY:
	You can target 1 "Red-Eyes" Gemini Monster you control;
	it is treated as an Effect Monster, and gains its effect(s).
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
s.listed_names={id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Lists : Gemini
s.listed_card_types={TYPE_GEMINI}
-- Helpers
function s.e1con(e,c)
	if c==nil then return true end

	local tp=e:GetHandlerPlayer()

	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.e2xfil(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
	or c:IsType(TYPE_FUSION)
	or c:IsType(TYPE_XYZ)
end
function s.e2con(e,tp)
	local c=e:GetHandler()

	return Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,c):GetCount()>0
	and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.e2fil(c,e,tp)
	return c:IsLevelBelow(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.e2con(e,tp)
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.e2evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	local gc=g:GetCount()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or gc==0 then return end

	local max=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if max<gc then max=gc end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max=1 end
	if max<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local sg=g:Select(tp,1,max,nil)
	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e3fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsType(TYPE_GEMINI)
	and c:IsMonster()
	and c:IsFaceup()
	and not c:IsGeminiStatus()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and s.e3fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil,tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.e3evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and s.e3fil(tc) then
		tc:EnableGeminiStatus()
	end
end
