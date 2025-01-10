-- Lord of Red Chaos
local s,id,o=GetID()
-- c220000002
function s.initial_effect(c)
	-- You can Ritual Summon this card with “Chaos Form” or “Red-Eyes Re-Transmigration”.
	c:EnableReviveLimit()
	--[[
	[SOPT]
	Once per turn, when a card or effect is activated, except “Lord of Red Chaos” (Quick Effect):
	You can target 1 monster on the field; destroy it.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[SOPT]
	Once per turn, when a card or effect is activated, except “Lord of Red Chaos” (Quick Effect):
	You can target 1 Spell/Trap on the field; destroy it.
	]]--
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[SOPT]
	If this card is sent from the field to the GY:
	You can Special Summon 1 Xyz Monster from your Extra Deck.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : Red-Eyes, Chaos
s.listed_series={0x3b,0xcf}
-- Helpers
function s.e1con(e,tp,eg,ep,ev,re)
	return not re:GetHandler():IsCode(id)
	and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
	end
	if chk==0 then
		return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end

	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)

	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e1evt(e)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsMonster() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.e2fil(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField()
		and s.e2fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	
	local g=Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e2evt(e)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.e3con(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e3fil(c,e,tp)
	return c:IsType(TYPE_XYZ)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
