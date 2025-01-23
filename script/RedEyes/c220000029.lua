-- Red-Eyes Mechanization
local s,id,o=GetID()
-- c220000029
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can add 1 "Red-Eyes" monster, 1 monster that mentions "Max Metalmorph", or 1 "Metalmorph" Trap from your Deck to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[SOPT]
	Once per turn: You can equip 1 "Max Metalmorph" from your Deck or GY to 1 "Red-Eyes" monster you control,
	and if you do, it becomes a Machine monster while equipped.
	(This is treated as being equipped by the effect of "Max Metalmorph".)
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	•
	The first time each "Red-Eyes" or Machine monster you control would be destroyed by battle
	during your opponent’s turn, it is not destroyed,
	and if you took battle damage from that battle, it gains that much ATK until the end of the turn,
	then you can set 1 "Metalmorph" Trap from your GY.
	•
	The first time each "Metalmorph" Trap you control would be destroyed by card effect, it is not destroyed.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetTargetRange(LOCATION_MZONE,0)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetTarget(s.e3atgt)
	e3a:SetValue(s.e3aval)
	c:RegisterEffect(e3a)

	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD)
	e3b:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3b:SetRange(LOCATION_SZONE)
	e3b:SetTargetRange(LOCATION_SZONE,0)
	e3b:SetCountLimit(1,{id,2})
	e3b:SetTarget(s.e3btgt)
	e3b:SetValue(s.e3bval)
	c:RegisterEffect(e3b)
end
-- Mentions : "Max Metalmorph"
s.listed_names={CARD_MAX_METALMORPH,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return ((c:IsSetCard(SET_RED_EYES) and c:IsMonster())
	or (c:ListsCode(CARD_MAX_METALMORPH) and c:IsMonster())
	or (c:IsSetCard(SET_METALMORPH) and c:IsTrap()))
	and c:IsAbleToHand()
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_DECK,0,nil)

	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		
		local sg=g:Select(tp,1,1,nil)

		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.e2fil1(c)
	return c:IsCode(CARD_MAX_METALMORPH)
end
function s.e2fil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsFaceup()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end
function s.e2lim(e,c)
	return c==e:GetLabelObject()
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g1=Duel.SelectMatchingCard(tp,s.e2fil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.e2fil2,tp,LOCATION_MZONE,0,1,1,nil)

	if g1:GetCount()>0 and g2:GetCount()>0 then
		local c=e:GetHandler()

		local ec=g1:GetFirst()
		local tc=g2:GetFirst()

		local e2e1=Effect.CreateEffect(c)
		e2e1:SetType(EFFECT_TYPE_SINGLE)
		e2e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2e1:SetCode(EFFECT_EQUIP_LIMIT)
		e2e1:SetValue(s.e2lim)
		e2e1:SetLabelObject(tc)
		e2e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2e1)
		
		local e2e2=Effect.CreateEffect(c)
		e2e2:SetType(EFFECT_TYPE_EQUIP)
		e2e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2e2:SetValue(400)
		e2e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2e2)

		local e2e3=e2e2:Clone()
		e2e3:SetCode(EFFECT_UPDATE_DEFENSE)
		ec:RegisterEffect(e2e3)
		
		local e2e4=Effect.CreateEffect(c)
		e2e4:SetType(EFFECT_TYPE_EQUIP)
		e2e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2e4:SetValue(function(_e,re,_rc,_c) return re:IsMonsterEffect() or re:IsSpellEffect() end)
		e2e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2e4)
		
		local e2e5=e2e4:Clone()
		e2e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2e5:SetValue(function(_e,re,rp) return rp==1-_e:GetHandlerPlayer() and (re:IsMonsterEffect() or re:IsSpellEffect()) end)
		ec:RegisterEffect(e2e5)

		local e2e6=Effect.CreateEffect(c)
		e2e6:SetType(EFFECT_TYPE_EQUIP)
		e2e6:SetCode(EFFECT_CHANGE_RACE)
		e2e6:SetValue(RACE_MACHINE)
		e2e6:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2e6)
	end
end
function s.e3afil(c)
	return c:IsSetCard(SET_METALMORPH)
	and c:IsTrap()
end
function s.e3atgt(e,c)
	return (c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_MACHINE))
end
function s.e3aval(e,re,r,rp)
	local c=e:GetHandler()
	
	if Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) and r&REASON_BATTLE~=0 then
		local tp=e:GetHandlerPlayer()
		local a=Duel.GetAttacker()
		local tc=a:GetBattleTarget()

		if tc and tc:IsControler(1-tp) then a,tc=tc,a end
		
		local dam=Duel.GetBattleDamage(tp)
		
		if not tc or dam<=0 then return 1 end
		
		local e3a1=Effect.CreateEffect(c)
		e3a1:SetType(EFFECT_TYPE_SINGLE)
		e3a1:SetCode(EFFECT_UPDATE_ATTACK)
		e3a1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3a1:SetRange(LOCATION_MZONE)
		e3a1:SetValue(dam)
		e3a1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3a1)

		Duel.BreakEffect()

		local g=Duel.GetMatchingGroup(s.e3afil,tp,LOCATION_GRAVE,0,nil)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)

			local sg=g:Select(tp,1,1,nil)
			Duel.SSet(tp,sg)
		end

		return 1
	else
		return 0
	end
end
function s.e3btgt(e,c)
	return c:IsSetCard(SET_METALMORPH)
	and c:IsTrap()
end
function s.e3bval(e,re,r,rp)
	if (r&REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
