-- Red-Eyes Resilience
local s,id,o=GetID()
-- c220000031
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[
	[SOPT]
	Once per turn: You can banish 1 "Red-Eyes Black Dragon" from your hand, Deck, or GY, then apply 1 of the following effects.
	•
	This turn, each time a "Red-Eyes" monster(s) is Special Summoned from your GY to your field,
	increase the ATK of all "Red-Eyes" monsters you currently control by the number of "Red-Eyes" monsters on the field x 400.
	Also, until the end of this turn, monsters your opponent controls lose 400 ATK for each "Red-Eyes" monster on the field.
	•
	This turn, each time your "Red-Eyes" monster destroys an opponent's monster by battle,
	or inflicts battle damage to your opponent by a direct attack,
	draw 1 card.
	•
	Destroy as many Spells/Traps your opponent controls as possible,
	and if you do, inflict 500 damage to your opponent for each card destroyed by this effect.
	•
	Destroy as many monsters your opponent controls as possible,
	and if you do, gain LP equal to half the combined ATK of those destroyed monsters.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsCode(CARD_REDEYES_B_DRAGON)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.e1evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

	local rg=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if rg:GetCount()>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) then
		Duel.BreakEffect()

		local c=e:GetHandler()

		local b3=Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>0
		local b4=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0

		local op=Duel.SelectEffect(tp,
			{aux.TRUE,aux.Stringid(id,1)},
			{aux.TRUE,aux.Stringid(id,2)},
			{b3,aux.Stringid(id,3)},
			{b4,aux.Stringid(id,4)})

		if op==1 then
			local e1a1=Effect.CreateEffect(c)
			e1a1:SetCategory(CATEGORY_ATKCHANGE)
			e1a1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
			e1a1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1a1:SetRange(LOCATION_SZONE)
			e1a1:SetCondition(s.e1acon)
			e1a1:SetOperation(s.e1aevt)
			c:RegisterEffect(e1a1)

			local ct=Duel.GetMatchingGroupCount(s.e1afil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

			local e1a2=Effect.CreateEffect(c)
			e1a2:SetCategory(CATEGORY_ATKCHANGE)
			e1a2:SetType(EFFECT_TYPE_FIELD)
			e1a2:SetCode(EFFECT_UPDATE_ATTACK)
			e1a2:SetTargetRange(0,LOCATION_MZONE)
			e1a2:SetValue(ct*-400)
			e1a2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1a2,tp)
		elseif op==2 then
			local e1b1=Effect.CreateEffect(c)
			e1b1:SetCategory(CATEGORY_DRAW)
			e1b1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
			e1b1:SetCode(EVENT_BATTLE_DESTROYING)
			e1b1:SetRange(LOCATION_SZONE)
			e1b1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1b1:SetCondition(s.e1b1con)
			e1b1:SetTarget(s.e1btgt)
			e1b1:SetOperation(s.e1bevt)
			e1b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1b1)

			local e1b2=Effect.CreateEffect(c)
			e1b2:SetCategory(CATEGORY_DRAW)
			e1b2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
			e1b2:SetCode(EVENT_BATTLE_DAMAGE)
			e1b2:SetRange(LOCATION_SZONE)
			e1b2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1b2:SetCondition(s.e1b2con)
			e1b2:SetTarget(s.e1btgt)
			e1b2:SetOperation(s.e1bevt)
			e1b2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1b2)
		elseif op==3 then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
			local ct=Duel.Destroy(g,REASON_EFFECT)
			if ct>0 then
				Duel.Damage(1-tp,ct*500,REASON_EFFECT)
			end
		elseif op==4 then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
			if Duel.Destroy(g,REASON_EFFECT)>0 then
				local dg=Duel.GetOperatedGroup()
				local sum=dg:GetSum(Card.GetAttack)
					
				Duel.Recover(tp,sum/2,REASON_EFFECT)
			end
		end
	end
end
function s.e1afil1(c,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsPreviousLocation(LOCATION_GRAVE)
	and c:IsPreviousControler(tp)
end
function s.e1afil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e1acon(e,tp,eg)
	local c=e:GetHandler()

	return not eg:IsContains(c)
	and eg:IsExists(s.e1afil1,1,nil,tp)
end
function s.e1aevt(e,tp)
	local g=Duel.GetMatchingGroup(s.e1afil2,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.e1afil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	local gs=g:GetFirst()
	for gs in aux.Next(g) do
		local e1a1=Effect.CreateEffect(c)
		e1a1:SetType(EFFECT_TYPE_SINGLE)
		e1a1:SetCode(EFFECT_UPDATE_ATTACK)
		e1a1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1a1:SetValue(400*ct)
		gs:RegisterEffect(e1a1)
	end
end
function s.e1b1con(e,tp,eg)
	local c=e:GetHandler()

	if not eg then return end
	
	for rc in aux.Next(eg) do
		if rc:IsStatus(STATUS_OPPO_BATTLE) then
			if rc:IsRelateToBattle() then
				if rc:IsControler(tp) and rc:IsSetCard(SET_RED_EYES) then return true end
			else
				if rc:IsPreviousControler(tp) and rc:IsPreviousSetCard(SET_RED_EYES) then return true end
			end
		end
	end
	return false
end
function s.e1btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.e1bevt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.e1b2con(e,tp,eg,ep)
	local tc=eg:GetFirst()
	
	return ep~=tp
	and tc:IsControler(tp)
	and tc:IsSetCard(SET_RED_EYES)
end
