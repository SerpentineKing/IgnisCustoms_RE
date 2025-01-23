-- Warriors of the Red-Eyes
local s,id,o=GetID()
-- c220000033
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can add 1 Level 4 or lower Warrior monster from your Deck or GY to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card leaves the field:
	You can Special Summon 1 Gemini monster from your Deck as an Effect Monster that gains its effects.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	When your Warrior monster targeted for an attack, OR when your Warrior monster(s) is destroyed:
	You can banish this card from your GY, then Tribute 1 Gemini Monster;
	Special Summon 1 FIRE Warrior from your hand or Deck,
	then if you Tributed a Gemini Monster that was an Effect Monster and had gained its effects to activate this effect,
	you can destroy 1 card on the field.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3a:SetCode(EVENT_BE_BATTLE_TARGET)
	e3a:SetRange(LOCATION_GRAVE)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetCost(s.e3cst)
	e3a:SetCondition(s.e3acon)
	e3a:SetTarget(s.e3tgt)
	e3a:SetOperation(s.e3evt)
	c:RegisterEffect(e3a)

	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3b:SetCode(EVENT_DESTROYED)
	e3b:SetRange(LOCATION_GRAVE)
	e3b:SetCountLimit(1,{id,2})
	e3b:SetCost(s.e3cst)
	e3b:SetCondition(s.e3bcon)
	e3b:SetTarget(s.e3tgt)
	e3b:SetOperation(s.e3evt)
	c:RegisterEffect(e3b)
	--[[
	[HOPT]
	•
	When an attack is declared involving your Dragon monster:
	You can Special Summon 1 Level 4 or lower Warrior monster from your hand or GY.
	•
	When an attack is declared involving your Warrior monster:
	You can Special Summon 1 Level 7 or lower "Red-Eyes" monster from your hand or GY in face-up Defense Position,
	but its effects are negated, also it cannot attack this turn.
	]]--
	local e4a=Effect.CreateEffect(c)
	e4a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4a:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4a:SetRange(LOCATION_SZONE)
	e4a:SetCountLimit(1,{id,3})
	e4a:SetCondition(s.e4acon)
	e4a:SetTarget(s.e4atgt)
	e4a:SetOperation(s.e4aevt)
	c:RegisterEffect(e4a)

	local e4b=Effect.CreateEffect(c)
	e4b:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4b:SetRange(LOCATION_SZONE)
	e4b:SetCountLimit(1,{id,3})
	e4b:SetCondition(s.e4bcon)
	e4b:SetTarget(s.e4btgt)
	e4b:SetOperation(s.e4bevt)
	c:RegisterEffect(e4b)
end
-- Geminize Lord Golknight
s.listed_card_types={TYPE_GEMINI}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsLevelBelow(4)
	and c:IsRace(RACE_WARRIOR)
	and c:IsAbleToHand()
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.e2fil(c,e,tp)
	return c:IsType(TYPE_GEMINI)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			tc:EnableGeminiStatus()
		end
		Duel.SpecialSummonComplete()
	end
end
function s.e3acon(e,tp)
	local d=Duel.GetAttackTarget()

	return d:IsFaceup()
	and d:IsControler(tp)
	and d:IsRace(RACE_WARRIOR)
end
function s.e3bfil(c,tp)
	return c:IsRace(RACE_WARRIOR)
	and c:IsMonster()
	and c:IsPreviousLocation(LOCATION_MZONE)
	and c:IsPreviousControler(tp)
end
function s.e3bcon(e,tp,eg)
	return eg:IsExists(s.e3bfil,1,nil,tp)
end
function s.e3fil1(c,tp)
	return c:IsType(TYPE_GEMINI)
	and c:IsMonster()
	and (c:IsControler(tp) or c:IsFaceup())
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,s.e3fil1,1,false,nil,nil,tp)
		and c:IsAbleToRemoveAsCost()
	end

	local sg=Duel.SelectReleaseGroupCost(tp,s.e3fil1,1,1,false,nil,nil,tp)
	
	local tc=sg:GetFirst()
	if tc:IsFaceup() and tc:IsGeminiStatus() then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end

	Duel.Release(sg,REASON_COST)

	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.e3fil2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE)
	and c:IsRace(RACE_WARRIOR)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3fil2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.e3evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3fil2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.BreakEffect()

			local c=e:GetHandler()
			local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			if e:GetLabel()==1 and dg:GetCount()>0 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				
				local sg=dg:Select(tp,1,1,nil)
				if sg:GetCount()>0 then
					Duel.Destroy(sg,REASON_EFFECT)
				end
			end
		end
	end
end
function s.e4acon(e,tp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then
		tc=Duel.GetAttackTarget()
	end
	
	return tc
	and tc:IsFaceup()
	and tc:IsControler(tp)
	and tc:IsRace(RACE_DRAGON)
end
function s.e4afil(c,e,tp)
	return c:IsLevelBelow(4)
	and c:IsRace(RACE_WARRIOR)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e4atgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e4afil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.e4aevt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e4afil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e4bcon(e,tp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then
		tc=Duel.GetAttackTarget()
	end
	
	return tc
	and tc:IsFaceup()
	and tc:IsControler(tp)
	and tc:IsRace(RACE_WARRIOR)
end
function s.e4bfil(c,e,tp)
	return c:IsLevelBelow(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.e4btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e4bfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.e4bevt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	local g=Duel.SelectMatchingCard(tp,s.e4bfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local c=e:GetHandler()
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local tc=g:GetFirst()

		local e4b1=Effect.CreateEffect(c)
		e4b1:SetType(EFFECT_TYPE_SINGLE)
		e4b1:SetCode(EFFECT_DISABLE)
		e4b1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4b1)

		local e4b2=Effect.CreateEffect(c)
		e4b2:SetType(EFFECT_TYPE_SINGLE)
		e4b2:SetCode(EFFECT_DISABLE_EFFECT)
		e4b2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4b2)

		local e4b3=Effect.CreateEffect(c)
		e4b3:SetDescription(3206)
		e4b3:SetType(EFFECT_TYPE_SINGLE)
		e4b3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e4b3:SetCode(EFFECT_CANNOT_ATTACK)
		e4b3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4b3)
	end
end
