-- Panther Warrior with Eyes of Red
local s,id,o=GetID()
-- c220000020
function s.initial_effect(c)
	--[[
	Cannot declare an attack unless you send 1 Level 7 or lower Dragon monster from your hand or Deck to the GY.
	If a monster is sent to the GY by this card’s effect:
	This card gains ATK equal to half the sent monster’s original ATK until the end of this turn.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetCost(s.e1cst)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[SOPT]
	Once per turn, during the Battle Phase (Quick Effect):
	You can activate this effect;
	this card can attack a number of times this Battle Phase, up to the number of cards sent to the GY this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetCondition(s.e2con)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(function(_,_,_,ep) Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect and sent to the GY:
	You can Special Summon any number of “Black Dragon’s Chick Tokens” (Dragon/DARK/Level 1/ATK 800/DEF 500),
	and if you do, each time 1 is destroyed, inflict 500 damage to your opponent.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsLevelBelow(7)
	and c:IsRace(RACE_DRAGON)
	and c:IsAbleToGraveAsCost()
end
function s.e1cst(e,c,tp)
	return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if Duel.IsAttackCostPaid()~=2 and c:IsLocation(LOCATION_MZONE) then
		local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,0,1,nil,1,tp,HINTMSG_TOGRAVE,function() return Duel.IsAttackCostPaid()==0 end,nil)
		if sg:GetCount()==1 then
			Duel.SendtoGrave(sg,REASON_COST)
			Duel.AttackCostPaid()

			local atk=sg:GetFirst():GetBaseAttack()/2

			local e1b=Effect.CreateEffect(c)
			e1b:SetType(EFFECT_TYPE_SINGLE)
			e1b:SetCode(EFFECT_UPDATE_ATTACK)
			e1b:SetValue(atk)
			e1b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1b)
		else
			Duel.AttackCostPaid(2)
		end
	end
end
function s.e2con(e,tp)
	local ph=Duel.GetCurrentPhase()
	return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function s.e2evt(e)
	local c=e:GetHandler()
	local ct=(Duel.GetFlagEffect(0,id)+Duel.GetFlagEffect(1,id))
	if ct>0 then
		local e2b=Effect.CreateEffect(c)
		e2b:SetType(EFFECT_TYPE_SINGLE)
		e2b:SetCode(EFFECT_EXTRA_ATTACK)
		e2b:SetRange(LOCATION_MZONE)
		e2b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2b:SetValue(ct)
		e2b:SetReset(RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e2b)
	end
end
function s.e3con(e,tp,eg,ep,ev,re,r)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
	and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,800,500,1,RACE_DRAGON,ATTRIBUTE_DARK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.e3evt(e,tp,eg,ep,ev,re,r,rp)
	local ft=5
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	ft=math.min(ft,Duel.GetLocationCount(tp,LOCATION_MZONE))

	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,800,500,1,RACE_DRAGON,ATTRIBUTE_DARK) then return end
	
	local c=e:GetHandler()
	local i=0
	repeat
		local token=Duel.CreateToken(tp,220000045)

		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local e3b=Effect.CreateEffect(c)
			e3b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e3b:SetCode(EVENT_LEAVE_FIELD)
			e3b:SetOperation(s.e3bevt)
			token:RegisterEffect(e3b,true)
		end

		ft=ft-1
		i=(i+1)%4
	until ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))
	Duel.SpecialSummonComplete()
end
function s.e3bevt(e)
	local c=e:GetHandler()
	Debug.ShowHint("DESTROY TOKEN")
	if c:IsReason(REASON_DESTROY) then
		local tp=c:GetPreviousControler()
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
	e:Reset()
end
