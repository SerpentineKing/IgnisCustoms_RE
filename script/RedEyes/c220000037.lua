-- Spell Card "Shield & Sword"
local s,id,o=GetID()
-- c220000037
function s.initial_effect(c)
	--[[
	Switch the original ATK/DEF of all face-up monsters your opponent currently controls until the end of this turn,
	then you can make 1 monster you control gain ATK equal to the combined differences.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
-- Helpers
function s.e1fil(c,e)
	return c:IsFaceup()
	and c:IsRelateToEffect(e)
	and not c:IsImmuneToEffect(e)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	Duel.SetTargetCard(g)
end
function s.e1evt(e,tp)
	local sg=Duel.GetMatchingGroup(s.e1fil,tp,0,LOCATION_MZONE,nil,e)
	local c=e:GetHandler()

	local total=0

	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		local e1b=Effect.CreateEffect(c)
		e1b:SetType(EFFECT_TYPE_SINGLE)
		e1b:SetCode(EFFECT_SWAP_BASE_AD)
		e1b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1b)

		local a=tc:GetBaseAttack()
		local d=tc:GetBaseDefense()
		local diff=a-d
		if d>a then
			diff=d-a
		end
		total=(total+diff)
	end

	Duel.BreakEffect()

	Duel.Hint(HINT_CARD,0,id)

	if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) then
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
			if g:GetCount()>0 then
				g:GetFirst():UpdateAttack(total)
			end
		end
	end
end
