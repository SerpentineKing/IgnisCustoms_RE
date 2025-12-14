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
	[HOPT]
	If this card is targeted for an attack by a monster with a higher Level than it,
	OR when your opponent's monster on the field activates its effect (Quick Effect):
	You can negate that attack or effect activation,
	and if you do, change that monster to face-down Defense Position,
	and if you do that, until your opponent's next turn, it cannot change its battle position, be Tributed,
	or used as material for the Summon of a monster from the Extra Deck.
	]]--
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_POSITION)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetCode(EVENT_BE_BATTLE_TARGET)
	e2a:SetCountLimit(1, {id,1})
	e2a:SetCondition(s.e2acon)
	e2a:SetOperation(s.e2evt)
	c:RegisterEffect(e2a)

	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,2))
	e2b:SetCategory(CATEGORY_POSITION+CATEGORY_NEGATE)
	e2b:SetType(EFFECT_TYPE_QUICK_O)
	e2b:SetCode(EVENT_CHAINING)
	e2b:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCountLimit(1, {id,1})
	e2b:SetCondition(s.e2bcon)
	e2b:SetTarget(s.e2btgt)
	e2b:SetOperation(s.e2evt)
	c:RegisterEffect(e2b)
	--[[
	[SOPT]
	You can target 1 “Red-Eyes” monster you control;
	equip this monster from your hand or field to it as an Equip Spell with the following effects.
	•
	Once per turn, when a monster declares an attack:
	You can switch the ATK and DEF of the attack target,
	and if you do, inflict damage to your opponent equal to the difference between the attack target’s current ATK and DEF,
	and if you do that, the attack target loses ATK equal to that amount.
	•
	Once per turn: You can target 1 monster you control;
	it gains ATK equal to the difference between its current ATK and DEF.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetCountLimit(1)
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
function s.e2lim(e,c)
	return c~=e:GetLabelObject()
end
function s.e2acon(e,tp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()

	return a:GetLevel()>c:GetLevel()
	and a:IsCanTurnSet()
end
function s.e2aevt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		local e2a0=Effect.CreateEffect(c)
		e2a0:SetType(EFFECT_TYPE_SINGLE)
		e2a0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2a0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW,2)

		local e2a1=e2a0:Clone()
		e2a1:SetDescription(3313)
		e2a1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2a1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e2a1)

		local e2a2=e2a0:Clone()
		e2a2:SetDescription(3303)
		e2a2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2a2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2a2:SetValue(1)
		tc:RegisterEffect(e2a2,true)

		local e2a3=e2a0:Clone()
		e2a3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2a3:SetValue(1)
		tc:RegisterEffect(e2a3,true)

		local e2a4=e2a0:Clone()
		e2a4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e2a4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		tc:RegisterEffect(e2a4)
	end
end
function s.e2bcon(e,tp,eg,ep,ev,re)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	and ep==1-tp
	and re:IsMonsterEffect()
	and Duel.IsChainNegatable(ev)
	and re:GetHandler():IsCanTurnSet()
end
function s.e2btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)

	if rc:IsAble(tp) and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,1,tp,0)
	end
end
function s.e2bevt(e,tp,eg,ep,ev,re)
	local c=e:GetHandler()
	local tc = re:GetHandler()

	if Duel.NegateActivation(ev) and tc:IsRelateToEffect(re) then
		if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
			local e2b0=Effect.CreateEffect(c)
			e2b0:SetType(EFFECT_TYPE_SINGLE)
			e2b0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2b0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW,2)

			local e2b1=e2b0:Clone()
			e2b1:SetDescription(3313)
			e2b1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e2b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			tc:RegisterEffect(e2b1)

			local e2b2=e2b0:Clone()
			e2b2:SetDescription(3303)
			e2b2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2b2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e2b2:SetValue(1)
			tc:RegisterEffect(e2b2,true)

			local e2b3=e2b0:Clone()
			e2b3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			e2b3:SetValue(1)
			tc:RegisterEffect(e2b3,true)

			local e2b4=e2b0:Clone()
			e2b4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e2b4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
			tc:RegisterEffect(e2b4)
		end
	end
end
function s.e3fil(c)
	return c:IsFaceup() and c:IsSetCard(SET_RED_EYES)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and s.e3fil(chkc)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.e3fil,tp,LOCATION_MZONE,0,1,c)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.e3evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end

	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:GetControler()==(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	
	Duel.Equip(tp,c,tc,true)

	local e3a1=Effect.CreateEffect(c)
	e3a1:SetType(EFFECT_TYPE_SINGLE)
	e3a1:SetCode(EFFECT_EQUIP_LIMIT)
	e3a1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3a1:SetLabelObject(tc)
	e3a1:SetValue(s.e3lim)
	c:RegisterEffect(e3a1)

	local e3a2=Effect.CreateEffect(c)
	e3a2:SetDescription(aux.Stringid(id,4))
	e3a2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3a2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3a2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3a2:SetRange(LOCATION_SZONE)
	e3a3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3a2:SetCountLimit(1)
	e3a2:SetCondition(s.e3a2con)
	e3a2:SetTarget(s.e3a2tgt)
	e3a2:SetOperation(s.e3a2evt)
	c:RegisterEffect(e3a2)

	local e3a3=Effect.CreateEffect(c)
	e3a3:SetDescription(aux.Stringid(id,5))
	e3a3:SetCategory(CATEGORY_ATKCHANGE)
	e3a3:SetType(EFFECT_TYPE_IGNITION)
	e3a3:SetRange(LOCATION_SZONE)
	e3a3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3a3:SetCountLimit(1)
	e3a3:SetTarget(s.e3a3tgt)
	e3a3:SetOperation(s.e3a3evt)
	c:RegisterEffect(e3a3)
end
function s.e3lim(e,c)
	return c==e:GetLabelObject()
end
function s.e3a2fil(c,tp)
	return c:IsFaceup()
	and c:IsRace(RACE_WARRIOR)
	and c:IsAttackAbove(1000)
	and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c)
end
function s.e3a2con(e,tp)
	local d=Duel.GetAttackTarget()

	return d and d:IsFaceup()
end
function s.e3a2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local d=0

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(d)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
end
function s.e3a2evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetAttackTarget()
	
	if tc then
		local e3b1=Effect.CreateEffect(c)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_SWAP_BASE_AD)
		e3b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3b1)

		local dmg = math.abs(tc:GetAttack() - tc:GetDefense())
		if dmg>0 then
			if Duel.Damage(1-tp,dmg,REASON_EFFECT)>0 then
				local e3b2=Effect.CreateEffect(c)
				e3b2:SetCategory(CATEGORY_ATKCHANGE)
				e3b2:SetType(EFFECT_TYPE_SINGLE)
				e3b2:SetCode(EFFECT_UPDATE_ATTACK)
				e3b2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e3b2:SetValue(-dmg)
				tc:RegisterEffect(e3b2)
			end
		end
	end
end
function s.e3a3fil(c)
	return c:IsFaceup()
end
function s.e3a3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp)
		and s.e3a3fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3a3fil,tp,LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.e3a3fil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.e3a3evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e3b3=Effect.CreateEffect(c)
		e3b3:SetCategory(CATEGORY_ATKCHANGE)
		e3b3:SetType(EFFECT_TYPE_SINGLE)
		e3b3:SetCode(EFFECT_UPDATE_ATTACK)
		e3b3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3b3:SetValue(math.abs(tc:GetAttack()-tc:GetDefense()))
		tc:RegisterEffect(e3b3)
	end
end
