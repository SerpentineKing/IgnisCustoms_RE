-- Red-Eyes Harpie Lady, Nightmare in the Darkness
local s,id,o=GetID()
-- c220000047
function s.initial_effect(c)
	-- If you control a "Red-Eyes" monster, you can Normal Summon this card without Tributing.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	--[[
	[SOPT]
	Once per turn, when this card destroys an opponent's monster by battle:
	Your opponent must discard 1 card.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	If this card is destroyed by battle or card effect:
	You can return 1 card on the field to the hand, and if you do, discard 1 card.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[SOPT]
	When your "Red-Eyes" monster is targeted for an attack by a monster with higher ATK than it:
	You can banish this card from your GY;
	halve the attack of the attacking monster during this Battle Phase only.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(aux.bfgcost)
	e4:SetCondition(s.e4con)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	During your Main Phase: You can activate 1 of these effects.
	•
	Destroy as many Spells/Traps your opponent controls as possible,
	and if you do, inflict 500 damage to your opponent for each card destroyed by this effect.
	•
	Destroy as many monsters your opponent controls as possible,
	and if you do, gain LP equal to half the combined ATK of those destroyed monsters.
	]]--
	local e5a=Effect.CreateEffect(c)
	e5a:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5a:SetDescription(aux.Stringid(id,2))
	e5a:SetType(EFFECT_TYPE_IGNITION)
	e5a:SetRange(LOCATION_MZONE)
	e5a:SetCountLimit(1,{id,0})
	e5a:SetTarget(s.e5atgt)
	e5a:SetOperation(s.e5aevt)
	c:RegisterEffect(e5a)

	local e5b=Effect.CreateEffect(c)
	e5b:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e5b:SetDescription(aux.Stringid(id,3))
	e5b:SetType(EFFECT_TYPE_IGNITION)
	e5b:SetRange(LOCATION_MZONE)
	e5b:SetCountLimit(1,{id,0})
	e5b:SetTarget(s.e5btgt)
	e5b:SetOperation(s.e5bevt)
	c:RegisterEffect(e5b)
end
-- Archetype : Red-Eyes, Harpie
s.listed_series={SET_RED_EYES,SET_HARPIE}
-- Helpers
function s.e1fil(c)
	return c:IsFaceup()
	and c:IsSetCard(SET_RED_EYES)
end
function s.e1con(e,c,minc)
	if c==nil then return true end

	return minc==0
	and c:GetLevel()>4
	and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(s.e1fil,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
function s.e2evt(e,tp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)

		local sg=g:Select(1-tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
	end
end
function s.e3con(e,tp,eg,ep,ev,re,r)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,tp,1)
	
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)

	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)

		local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0,nil)
		if hg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)

			local sg=hg:Select(tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
		end
	end
end
function s.e4con(e,tp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	return (d and d:IsFaceup())
	and d:IsControler(tp)
	and d:IsSetCard(SET_RED_EYES)
	and a:GetAttack()>d:GetAttack()
end
function s.e4evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()

	if tc and c:IsRelateToEffect(e) then
		local e4b=Effect.CreateEffect(c)
		e4b:SetType(EFFECT_TYPE_SINGLE)
		e4b:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4b:SetValue(tc:GetAttack()/2)
		e4b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e4b)
	end
end
function s.e5atgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(1-tp,LOCATION_SZONE,0)>0
	end

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
end
function s.e5aevt(e,tp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
function s.e5btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>0
	end

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.e5bevt(e,tp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local dg=Duel.GetOperatedGroup()
		local sum=dg:GetSum(Card.GetAttack)
			
		Duel.Recover(tp,sum/2,REASON_EFFECT)
	end
end
