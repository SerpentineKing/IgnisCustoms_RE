-- Red-Eyes Onslaught Dragon
local s,id,o=GetID()
-- c220000015
function s.initial_effect(c)
	--[[
	[HOPT]
	You can reveal this card in your hand;
	add 1 card that has “Red-Eyes” in its text from your Deck to your hand, except “Red-Eyes Onslaught Dragon”,
	and if you do, shuffle this card into the Deck.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(aux.SelfRevealCost)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	Each time your opponent activates a card or effect,
	you can make 1 face-up monster your opponent controls lose 400 ATK when it resolves,
	and if you do, inflict 500 damage to your opponent.
	]]--
	local e2a=Effect.CreateEffect(c)
	e2a:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCondition(s.e2acon)
	e2a:SetOperation(s.e2aevt)
	c:RegisterEffect(e2a)

	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_CHAIN_SOLVED)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(s.e2bcon)
	e2b:SetOperation(s.e2bevt)
	c:RegisterEffect(e2b)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return (c:IsSetCard(SET_RED_EYES)
	or c:IsSetCard(0xfe1)
	or c:IsCode(36262024)
	or c:IsCode(93969023)
	or c:IsCode(66574418)
	or c:IsCode(11901678)
	or c:IsCode(45349196)
	or c:IsCode(90660762)
	or c:IsCode(19025379)
	or c:IsCode(71408082)
	or c:IsCode(71408082)
	or c:IsCode(32566831)
	or c:IsCode(52684508)
	or c:IsCode(18803791))
	and not c:IsCode(id)
	and c:IsAbleToHand()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	
	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.e2acon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.e2aevt(e)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN&~RESET_TURN_SET,0,1)
end
function s.e2bcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	return rp==1-tp
	and c:HasFlagEffect(id)
end
function s.e2bevt(e,tp)
	Duel.Hint(HINT_CARD,0,id)

	if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
		local c=e:GetHandler()
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
			if g:GetCount()>0 then
				if g:GetFirst():UpdateAttack(-400)<0 then
					Duel.Damage(1-tp,500,REASON_EFFECT)
				end
			end
		end
	end
end
