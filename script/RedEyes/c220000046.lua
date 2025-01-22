-- Little-Winguard with Eyes of Red
local s,id,o=GetID()
-- c220000046
function s.initial_effect(c)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can target 1 Level 1 Dragon monster in your GY;
	add it to your hand.
	]]--
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.e1tgt)
	e1a:SetOperation(s.e1evt)
	c:RegisterEffect(e1a)

	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--[[
	[SOPT]
	Once per turn, when your opponent’s monster effect activated on the field resolves,
	while this card is equipped to a "Red-Eyes" monster,
	you can change the monster that activated that effect to face-down Defense Position.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.e2con)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[SOPT]
	Once per turn, during the Battle Phase (Quick Effect):
	You can switch the ATK and DEF of 1 face-up monster your opponent controls until the end of this Battle Phase.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsLevel(1)
	and c:IsRace(RACE_DRAGON)
	and c:IsMonster()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLevel(1)
		and chkc:IsRace(RACE_DRAGON)
		and chkc:IsMonster()
		and chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsOwner(tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1fil,tp,LOCATION_GRAVE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.e1fil,tp,LOCATION_GRAVE,0,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()

	return rp==1-tp
	and re:IsActiveType(TYPE_MONSTER)
	and re:GetHandler():IsLocation(LOCATION_MZONE)
	and c:GetFlagEffect(id)==0
	and (ec and ec:IsSetCard(SET_RED_EYES))
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)

	if Duel.GetFlagEffectLabel(tp,id)==cid or not Duel.SelectEffectYesNo(tp,c) then return end

	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1,cid)

	Duel.Hint(HINT_CARD,0,id)
	local rc=re:GetHandler()
	if rc:IsLocation(LOCATION_MZONE) and rc:IsRelateToEffect(re) then
		Duel.ChangePosition(rc,POS_FACEDOWN_DEFENSE)
	end
end
function s.e3con(e,tp)
	return Duel.IsBattlePhase()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
	
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	
	if tc then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()

		local e3b1=Effect.CreateEffect(c)
		e3b1:SetCategory(CATEGORY_ATKCHANGE)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3b1:SetValue(def)
		e3b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e3b1)

		local e3b2=Effect.CreateEffect(c)
		e3b2:SetCategory(CATEGORY_DEFCHANGE)
		e3b2:SetType(EFFECT_TYPE_SINGLE)
		e3b2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e3b2:SetValue(atk)
		e3b2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e3b2)
	end
end
