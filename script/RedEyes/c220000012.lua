-- Red-Eyes Eternal Darkness Dragon
local s,id,o=GetID()
-- c220000012
function s.initial_effect(c)
	-- Cannot be Normal Summoned/Set.
	c:EnableReviveLimit()
	--[[
	[HOPT]
	Must be Special Summoned (from your hand) by Tributing 1 Level 7 or higher “Red-Eyes” monster from your hand or field,
	and cannot be Special Summoned by other ways.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1b:SetValue(aux.FALSE)
	c:RegisterEffect(e1b)
	-- Gains 600 ATK for each Dragon monster on the field and in the GYs.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	-- Special Summoned monsters your opponent controls cannot attack the turn they are Summoned.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.e3tgt)
	c:RegisterEffect(e3)
	--[[
	[SOPT]
	Once per turn (Quick Effect):
	You can discard 1 card, then target 1 face-up card your opponent controls;
	negate its effects until the end of this turn.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e4:SetCountLimit(1)
	e4:SetCost(s.e4cst)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	When this card destroys an opponent’s Special Summoned monster by battle:
	Inflict damage to your opponent equal to the destroyed monster’s original ATK.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevelAbove(7)
	and c:IsMonster()
end
function s.e1con(e,c)
	if c==nil then return true end

	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.e1fil,1,true,1,true,c,tp,nil,false,e:GetHandler())
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.e1fil,1,1,true,true,true,c,tp,nil,false,e:GetHandler())
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.e2val(e,c)
	return 600*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_DRAGON),0,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
end
function s.e3tgt(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN)
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end

	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp)
		and chkc:IsOnField()
		and chkc:IsNegatable()
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.e4evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)

		local e4b=Effect.CreateEffect(c)
		e4b:SetType(EFFECT_TYPE_SINGLE)
		e4b:SetCode(EFFECT_DISABLE)
		e4b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4b)
		
		local e4c=e4b:Clone()
		e4c:SetCode(EFFECT_DISABLE_EFFECT)
		e4c:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e4c)
		
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e4d=e4b:Clone()
			e4d:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e4d)
		end
	end
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	local tc=e:GetHandler():GetBattleTarget()
	local atk=tc:GetBaseAttack()

	if atk<0 then
		atk=0
	end

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.e5evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
