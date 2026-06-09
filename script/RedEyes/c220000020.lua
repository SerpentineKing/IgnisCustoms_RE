-- Red-Eyes Furious Six
local s,id,o=GetID()
-- c220000020
function s.initial_effect(c)
	-- 2 Level 6 DARK monsters
	Xyz.AddProcedure(c,s.m1fil,6,2)
	c:EnableReviveLimit()
	--[[
	If this card is Xyz Summoned: Roll a six-sided die.
	All face-up monsters your opponent currently controls lose ATK/DEF equal to the result x 300,
	until the end of this turn.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	You can detach 1 material from this card;
	Special Summon from your Extra Deck, 1 Rank 7 "Red-Eyes" Xyz Monster,
	by using this face-up card you control as material,
	but destroy it during your opponent's next End Phase.
	(This is treated as an Xyz Summon. Transfer its materials to the Summoned monster.)
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
local RESETS_END_PHASE = RESET_PHASE+PHASE_END
local RESETS_OPP_END_PHASE = RESETS_STANDARD_PHASE_END+RESET_OPPO_TURN
s.listed_names={id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.m1fil(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function s.e1con(e,tp)
	local c=e:GetHandler()

	return c:IsXyzSummoned()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end

	local res=Duel.TossDice(tp,1)

	for tc in g:Iter() do
		local e1b1=Effect.CreateEffect(c)
		e1b1:SetType(EFFECT_TYPE_SINGLE)
		e1b1:SetCode(EFFECT_UPDATE_ATTACK)
		e1b1:SetValue(res*-300)
		e1b1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1b1)

		local e1b2=e1b1:Clone()
		e1b2:SetType(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e1b2)
	end
end
function s.e2fil(c,e,tp,mc,rk,pg)
	return c:IsRank(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsType(TYPE_XYZ)
	and c:IsMonster()
	and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
	and (pg:GetCount()<=0 or pg:IsContains(mc))
	and mc:IsCanBeXyzMaterial(c,tp)
	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		
		return (pg:GetCount()<=0 or (pg:GetCount()==1 and pg:IsContains(c)))
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank(),pg)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)

	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

		local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,c:GetRank(),pg)
		
		local sc=g:GetFirst()
		if sc then
			sc:SetMaterial(c)
			Duel.Overlay(sc,c)
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()

				local e2b1=Effect.CreateEffect(c)
				e2b1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2b1:SetCode(RESETS_END_PHASE)
				e2b1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2b1:SetCountLimit(1)
				e2b1:SetCondition(s.e2b1con)
				e2b1:SetOperation(s.e2b1evt)
				e2b1:SetLabelObject(sc)
				e2b1:SetReset(RESETS_OPP_END_PHASE)
				sc:RegisterFlagEffect(id,RESETS_OPP_END_PHASE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
				Duel.RegisterEffect(e2b1,tp)
			end
		end
	end
end
function s.e2b1con(e,tp)
	return Duel.IsTurnPlayer(1-tp)
	and e:GetLabelObject():GetFlagEffect(id)>0
end
function s.e2b1evt(e,tp)
	local sc=e:GetLabelObject()
	Duel.Destroy(sc,REASON_EFFECT)
end
