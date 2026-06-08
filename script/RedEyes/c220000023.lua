-- Red-Eyes Potential
local s,id,o=GetID()
-- c220000023
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- "Red-Eyes" Gemini Monsters are treated as Normal Monsters while in your hand or Deck.
	local e1a1=Effect.CreateEffect(c)
	e1a1:SetType(EFFECT_TYPE_FIELD)
	e1a1:SetCode(EFFECT_ADD_TYPE)
	e1a1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a1:SetRange(LOCATION_SZONE)
	e1a1:SetTargetRange(LOCATION_HAND+LOCATION_DECK,0)
	e1a1:SetTarget(aux.TargetBoolFunction(s.e1fil))
	e1a1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1a1)

	local e1a2=e1a1:Clone()
	e1a2:SetCode(EFFECT_REMOVE_TYPE)
	e1a2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e1a2)
	--[[
	[H1PT]
	You can target 1 "Red-Eyes" Xyz Monster you control;
	attach 1 Level 7 or lower "Red-Eyes" monster from your hand or Deck to that monster as material.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
s.listed_names={id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Lists : Gemini
s.listed_card_types={TYPE_GEMINI}
-- Helpers
function s.e1fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsType(TYPE_GEMINI)
	and c:IsMonster()
end
function s.e2fil1(c,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsType(TYPE_XYZ)
	and c:IsMonster()
	and c:IsFaceup()
	and Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
end
function s.e2fil2(c)
	return c:IsLevelBelow(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsControler(tp)
		and chkc:IsLocation(LOCATION_MZONE)
		and s.e1fil1(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil1,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.e2fil1,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then return end
	
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		
		local g=Duel.SelectMatchingCard(tp,s.e2fil2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,tc)
		if g:GetCount()>0 then
			Duel.Overlay(tc,g,true)
		end
	end
end
