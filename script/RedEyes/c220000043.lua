-- Red-Eyes Magical Arm Shield
local s,id,o=GetID()
-- c220000043
function s.initial_effect(c)
	--[[
	When a monster is targeted for an attack,
	while your opponent controls 2 or more monsters:
	Target 1 monster your opponent controls, except the battling monster, and 1 face-up monster you control;
	equip the first target and this card to the second target.
	The equipped monster gains the following effects.
	•
	This card gains ATK/DEF equal to the combined ATK/DEF of all Monster Cards equipped to it.
	•
	If this card destroys a monster by battle:
	Inflict damage to the destroyed monster’s controller equal to the ATK of the destroyed monster.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1con(e,tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	return g:GetCount()>=2
end
function s.e1fil(c)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	return not (c==a or c==d)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1fil,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g1=Duel.SelectTarget(tp,s.e1fil,tp,0,LOCATION_MZONE,1,1,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,0,0)
	e:SetLabelObject(g2:GetFirstTarget())
end
function s.e1lim(e,c)
	return c==e:GetLabelObject()
end
function s.e1evt(e,tp)
	local ec=e:GetLabelObject()
	if not (ec:IsRelateToEffect(e) and ec:IsControler(tp)) then return end
	
	local tc=(Duel.GetTargetCards(e)-ec):GetFirst()
	if not (tc and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
		Duel.SendtoGrave(ec,REASON_RULE,PLAYER_NONE,PLAYER_NONE)
	else
		local c=e:GetHandler()

		if Duel.Equip(tp,ec,tc) then
			local e1b1=Effect.CreateEffect(c)
			e1b1:SetType(EFFECT_TYPE_SINGLE)
			e1b1:SetCode(EFFECT_EQUIP_LIMIT)
			e1b1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1b1:SetValue(s.e1lim)
			e1b1:SetLabelObject(ec)
			tc:RegisterEffect(e1b1)

			c:CancelToGrave()
			if Duel.Equip(tp,ec,c) then
				local e1b2=Effect.CreateEffect(c)
				e1b2:SetType(EFFECT_TYPE_SINGLE)
				e1b2:SetCode(EFFECT_EQUIP_LIMIT)
				e1b2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1b2:SetValue(s.e1lim)
				e1b2:SetLabelObject(ec)
				c:RegisterEffect(e1b2)

				local e2c1=Effect.CreateEffect(c)
				e2c1:SetType(EFFECT_TYPE_EQUIP)
				e2c1:SetCode(EFFECT_UPDATE_ATTACK)
				e2c1:SetValue(tc:GetBaseAttack())
				e2c1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e2c1)

				local e2c2=e2c1:Clone()
				e2c2:SetCode(EFFECT_UPDATE_DEFENSE)
				e2c2:SetValue(tc:GetBaseDefense())
				ec:RegisterEffect(e2c2)

				local e2c3=Effect.CreateEffect(c)
				e2c3:SetType(EFFECT_TYPE_EQUIP)
				e2c3:SetCode(EVENT_BATTLE_DESTROYING)
				e2c3:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2c3:SetTarget(s.e2ctgt)
				e2c3:SetOperation(s.e2cevt)
				ec:RegisterEffect(e2c3)
			end
		end
	end
end
function s.e2ctgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	local tc=e:GetHandler():GetBattleTarget()
	local atk=tc:GetAttack()

	if atk<0 then
		atk=0
	end

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.e2cevt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
