-- Piercing Red-Eyes from the Darkness
local s,id,o=GetID()
-- c220000042
function s.initial_effect(c)
	--[[
	[HOPT]
	When your opponent activates a card or effect when your "Red-Eyes" monster(s) is Normal or Special Summoned:
	Negate the activation,
	and if you do, you can shuffle up to 2 cards your opponent controls into the Deck,
	then take damage equal to half the ATK of 1 "Red-Eyes" monster in your hand, GY, or on your field.
	]]--
	-- TODO : Set "Red-Eyes" requirement
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS) -- EVENT_CHAINING
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--[[
	[HOPT]
	If a "Red-Eyes" monster(s) you control that cannot be Normal Summoned/Set is sent to your GY or banishment:
	You can banish this card from your GY, then target 1 of those monsters;
	Special Summon it, ignoring its Summoning conditions.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	local e2b=e2:Clone()
	e2b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2b)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil1(c,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:GetControler()==tp
end
function s.e1con(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain()

	local req=false
	if ch>=1 then
		local ch_ev=ch-1
		local ch_p,ch_e=Duel.GetChainInfo(tev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)

		if (ch_e:GetCode()==EVENT_SUMMON_SUCCESS or ch_e:GetCode()==EVENT_SPSUMMON_SUCCESS) and Duel.IsChainNegatable(ch_ev) and ch_p~=tp then
			req=true
		end
	end

	return req
	and eg:IsExists(s.e1fil1,1,nil,tp)
end
function s.e1fil2(c)
	return c:IsAbleToDeck()
end
function s.e1fil3(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and (c:IsFaceup() or not c:IsLocation(LOCATION_ONFIELD))
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,2,0,LOCATION_ONFIELD)
	end
end
function s.e1evt(e,tp,eg,ep,ev,re)
	Debug.ShowHint("CALL")
	--[[
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		local g=Duel.GetMatchingGroup(s.e1fil2,tp,0,LOCATION_ONFIELD,nil)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)

			local sg=g:Select(tp,1,2,nil)
			local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			if ct>0 then
				Duel.BreakEffect()

				local g2=Duel.GetMatchingGroup(s.e1fil3,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
				
				if g2:GetCount()==0 then return end

				local sg2=g2:Select(tp,1,1,nil)
				Duel.ConfirmCards(1-tp,sg2)

				local cc=sg2:GetFirst()
				Duel.Damage(tp,cc:GetAttack()/2,REASON_EFFECT)
			end
		end
	end
	]]--
end
function s.e2fil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and not c:IsSummonableCard()
	and c:GetPreviousControler()==tp
	and c:IsCanBeEffectTarget(e)
	and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return eg:IsContains(chkc)
		and s.e2fil(chkc,e,tp)
	end
	if chk==0 then
		return eg:IsExists(s.e2fil,1,nil,e,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	local g=eg:FilterSelect(tp,s.e2fil,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
