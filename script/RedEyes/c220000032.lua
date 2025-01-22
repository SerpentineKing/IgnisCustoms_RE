-- Red-Eyes Zombification
local s,id,o=GetID()
-- c220000032
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated: You can activate 1 of the following effects.
	•
	Target 1 "Red-Eyes" non-Tuner monster you control;
	it is treated as a Tuner this turn.
	•
	Discard 1 Level 7 or lower "Red-Eyes" non-Tuner monster;
	add 1 "Red-Eyes" Tuner monster from your Deck to your hand.
	]]--
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetCode(EVENT_FREE_CHAIN)
	e1a:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1a)

	local e1b=e1a:Clone()
	e1b:SetDescription(aux.Stringid(id,1))
	e1b:SetTarget(s.e1btgt)
	e1b:SetOperation(s.e1bevt)
	c:RegisterEffect(e1b)

	local e1c=e1a:Clone()
	e1c:SetDescription(aux.Stringid(id,2))
	e1c:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1c:SetCost(s.e1ccst)
	e1c:SetTarget(s.e1ctgt)
	e1c:SetOperation(s.e1cevt)
	c:RegisterEffect(e1c)
	--[[
	[HOPT]
	You can send 1 Level 7 or higher "Red-Eyes" monster from your Deck to the GY;
	this turn, all "Red-Eyes" monsters on the field and in the GYs become Zombie monsters.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.e2cst)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	When a "Red-Eyes" monster declares an attack:
	You can target 1 monster in either GY;
	equip it to a "Red-Eyes" Synchro Monster you control as an Equip Spell that gives it 200 ATK.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	When a card or effect is activated that targets a "Red-Eyes" card(s) you control:
	You can destroy this card;
	negate the activation, and if you do, destroy that card.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(s.e4cst)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1bfil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsNotTuner()
end
function s.e1btgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsNotTuner()
		and chkc:IsSetCard(SET_RED_EYES)
		and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1bfil,tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)

	local g=Duel.SelectTarget(tp,s.e1bfil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.e1bevt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1b1=Effect.CreateEffect(c)
		e1b1:SetType(EFFECT_TYPE_SINGLE)
		e1b1:SetCode(EFFECT_ADD_TYPE)
		e1b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1b1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1b1)
	end
end
function s.e1cfil1(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsNotTuner()
	and c:IsLevelBelow(7)
	and c:IsMonster()
	and c:IsDiscardable()
end
function s.e1ccst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1cfil1,tp,LOCATION_HAND,0,1,nil)
	end

	Duel.DiscardHand(tp,s.e1cfil1,1,1,REASON_COST+REASON_DISCARD)
end
function s.e1cfil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and not c:IsNotTuner()
	and c:IsMonster()
	and c:IsAbleToHand()
end
function s.e1ctgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1cfil2,tp,LOCATION_DECK,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e1cevt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e1cfil2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e2fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevelAbove(7)
	and c:IsMonster()
	and c:IsAbleToGraveAsCost()
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.e2evt(e,tp)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e2b:SetCode(EFFECT_CHANGE_RACE)
	e2b:SetValue(RACE_ZOMBIE)
	e2b:SetTarget(s.e2btgt)
	e2b:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2b,tp)
end
function s.e2btgt(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end

		c:ResetFlagEffect(1)
		
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end

	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e3con(e)
	return Duel.GetAttacker():IsSetCard(SET_RED_EYES)
end
function s.e3fil1(c,tp)
	return c:CheckUniqueOnField(tp)
	and c:IsMonster()
	and not c:IsForbidden()
end
function s.e3fil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsType(TYPE_SYNCHRO)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and s.e3fil(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.e3fil2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	
	local g=Duel.SelectTarget(tp,s.e3fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.e3lim(e,c)
	return c==e:GetLabelObject()
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.e3fil2,tp,LOCATION_MZONE,0,1,1,nil)
	local ec=g:GetFirst()

	local tc=Duel.GetFirstTarget()
	if g:GetCount()>0 and tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,ec,true) then
		local e3b1=Effect.CreateEffect(c)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_EQUIP_LIMIT)
		e3b1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3b1:SetValue(s.e3lim)
		e3b1:SetLabelObject(ec)
		tc:RegisterEffect(e3b1)
		
		local e3b2=Effect.CreateEffect(c)
		e3b2:SetType(EFFECT_TYPE_EQUIP)
		e3b2:SetCode(EFFECT_UPDATE_ATTACK)
		e3b2:SetValue(200)
		e3b2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3b2)
	end
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDestructable()
	end

	Duel.Destroy(c,REASON_COST)
end
function s.e4fil(c,tp)
	return c:IsControler(tp)
	and c:IsLocation(LOCATION_ONFIELD)
	and c:IsFaceup()
	and c:IsSetCard(SET_RED_EYES)
end
function s.e4con(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end

	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)

	return g and g:IsExists(s.e4fil,1,nil,tp)
	and Duel.IsChainNegatable(ev)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)

	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
