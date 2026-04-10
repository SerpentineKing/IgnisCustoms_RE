-- Lord of the Red Chaos
local s,id,o=GetID()
-- c220000002
function s.initial_effect(c)
	-- You can Ritual Summon this card with "Red-Eyes Re-Transmigration".
	c:EnableReviveLimit()
	--[[
	[S2PC]
	Twice per turn, when a card or effect is activated (Quick Effect):
	You can destroy 1 card on the field,
	and if you do, inflict 500 damage to your opponent,
	also if you destroyed a card you control by this effect, negate that activated effect.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	If this Ritual Summoned card is destroyed:
	You can target 1 Level 7 or lower "Red-Eyes" monster in your GY;
	Special Summon it, but it cannot attack directly this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
local CARD_RED_EYES_RE_TRANSMIGRATION = 220000038
-- Mentions : "Red-Eyes Re-Transmigration"
s.listed_names={CARD_RED_EYES_RE_TRANSMIGRATION,id}
-- Archetype : Red-Eyes, Chaos
s.listed_series={SET_RED_EYES,SET_CHAOS}
-- Helpers
function s.e1con(e,tp,eg,ep,ev)
	return Duel.IsChainDisablable(ev)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local gc=g:GetCount()
	
	if chk==0 then
		return gc>0
		and Duel.GetFlagEffect(tp,id)==0
	end

	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	
	local dmg = 500
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.e1evt(e,tp,eg,ep,ev)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		local ap=tc:GetControler()
		
		Duel.HintSelection(g)
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			local dmg = 500
			Duel.Damage(1-tp,dmg,REASON_EFFECT)

			if ap==tp then
				Duel.NegateEffect(ev)
			end
		end
	end

	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(id,1))
end
function s.e2con(e,tp)
	local c=e:GetHandler()

	return c:IsRitualSummoned()
	and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.e2fil(c,e,tp)
	return c:IsLevelBelow(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e2b1=Effect.CreateEffect(c)
		e2b1:SetDescription(3207)
		e2b1:SetType(EFFECT_TYPE_SINGLE)
		e2b1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2b1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2b1)
	end
	Duel.SpecialSummonComplete()
end
