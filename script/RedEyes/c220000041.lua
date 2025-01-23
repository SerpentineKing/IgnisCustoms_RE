-- Descent into Darkness
local s,id,o=GetID()
-- c220000041
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	Activate this card by targeting 1 "Red-Eyes" monster you control; apply the following effects,
	also, you can add 1 "Red-Eyes" monster that cannot be Normal Summoned/Set from your Deck or GY to your hand.
	•
	It gains 1000 ATK.
	•
	Banish any monster destroyed by battle with that target.
	•
	When that monster leaves the field, destroy this card.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	When your opponent activates a monster effect that targets a "Red-Eyes" monster you control:
	You can target 1 face-up monster your opponent controls;
	inflict damage to your opponent equal to the original ATK of that target,
	and if you do, return that target to the hand.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1fil1(c)
	return c:IsSetCard(SET_RED_EYES)
end
function s.e1fil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and not c:IsSummonableCard()
	and c:IsAbleToHand()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsSetCard(SET_RED_EYES)
		and chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(aux.FaceupFilter(s.e1fil1),tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.e1fil1,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.e1evt(e,tp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()

	if tc:IsRelateToEffect(e) then
		local e1b1=Effect.CreateEffect(c)
		e1b1:SetCategory(CATEGORY_ATKCHANGE)
		e1b1:SetType(EFFECT_TYPE_SINGLE)
		e1b1:SetCode(EFFECT_UPDATE_ATTACK)
		e1b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1b1:SetValue(1000)
		e1b1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1b1)

		local e1b2=Effect.CreateEffect(c)
		e1b2:SetType(EFFECT_TYPE_SINGLE)
		e1b2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
		e1b2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1b2:SetValue(LOCATION_REMOVED)
		e1b2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1b2)

		local e1b3=Effect.CreateEffect(c)
		e1b3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1b3:SetRange(LOCATION_SZONE)
		e1b3:SetCode(EVENT_LEAVE_FIELD)
		e1b3:SetLabelObject(tc)
		e1b3:SetCondition(s.e1bcon)
		e1b3:SetOperation(s.e1bevt)
		c:RegisterEffect(e1b3)
	end

	local g=Duel.GetMatchingGroup(s.e1fil2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.e1bcon(e,tp,eg)
	local tc=e:GetLabelObject()
	return tc and eg:IsContains(tc)
end
function s.e1bevt(e,tp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.e2fil(c,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsControler(tp)
	and c:IsLocation(LOCATION_MZONE)
end
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end

	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.e2fil,1,nil,tp)
	and re:IsActiveType(TYPE_MONSTER)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp)
		and chkc:IsFaceup()
		and chkc:IsAbleToHand()
		and chkc:IsLocation(LOCATION_MZONE)
	end
	if chk==0 then
		return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)

	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)>0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
