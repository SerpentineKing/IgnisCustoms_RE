-- Red-Eyes Trunade!
local s,id,o=GetID()
-- c220000035
function s.initial_effect(c)
	--[[
	When your opponent activates a card or effect when your “Red-Eyes” monster(s) is Normal or Special Summoned,
	OR when your opponent activates a card or effect during the Battle Phase:
	Negate the activation,
	and if you do, shuffle that card and all Set cards your opponent controls into the Deck/Extra Deck,
	and if you do that, inflict 500 damage to your opponent for each card returned to the Deck/Extra Deck by this effect.
	]]--
	-- TODO : Set "Red-Eyes" requirement
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.e1acon)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)

	local e1b=Effect.CreateEffect(c)
	e1b:SetDescription(aux.Stringid(id,0))
	e1b:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1b:SetType(EFFECT_TYPE_ACTIVATE)
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1b:SetCondition(s.e1bcon)
	e1b:SetTarget(s.e1tgt)
	e1b:SetOperation(s.e1evt)
	c:RegisterEffect(e1b)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil1(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:GetControler()==tp
end
function s.e1acon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
	and Duel.IsChainNegatable(ev)
	and (re:GetCode()==EVENT_SUMMON_SUCCESS
	or re:GetCode()==EVENT_SPSUMMON_SUCCESS)
end
function s.e1bcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
	and Duel.IsChainNegatable(ev)
	and Duel.IsBattlePhase()
end
function s.e1fil2(c)
	return c:IsFacedown()
	and c:IsAbleToDeck()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.e1evt(e,tp,eg,ep,ev,re)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		rc:CancelToGrave()

		local g=Duel.GetMatchingGroup(s.e1fil2,tp,0,LOCATION_ONFIELD,nil)
		g:AddCard(rc)

		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if ct>0 then
			Duel.Damage(1-tp,500*ct,REASON_EFFECT)
		end
	end
end
