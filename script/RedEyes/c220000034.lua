-- Wizards of the Red-Eyes
local s,id,o=GetID()
-- c220000034
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can add 1 Level 5 or lower Spellcaster monster from your Deck to your hand.
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
	During your Main Phase:
	You can send 1 Spellcaster monster from your hand or face-up field to the GY; apply 1 of the following effects.
	•
	Special Summon 1 “Red-Eyes" monster from your hand or GY, ignoring its Summoning conditions,
	but it cannot attack this turn.
	•
	Fusion Summon 1 Fusion Monster that lists a “Red-Eyes” monster as material from your Extra Deck,
	by shuffling Fusion Materials listed on it from your GY into the Deck/Extra Deck.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If a Spellcaster monster(s) you control is sent to the GY by a card effect,
	while this card is in your GY (except during the Damage Step): You can banish this card;
	add 1 “Fusion” card from your Deck or GY to your hand.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsLevelBelow(5)
	and c:IsRace(RACE_SPELLCASTER)
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
function s.e2fil(c)
	return c:IsRace(RACE_SPELLCASTER)
	and c:IsMonster()
	and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
	and c:IsAbleToGraveAsCost()
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	
	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.e2afil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local fparams={handler=c,fusfilter=aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial,SET_RED_EYES),matfilter=Card.IsAbleToDeck,extrafil=s.efil,extraop=Fusion.ShuffleMaterial,extratg=s.tfil}
	local fustg=Fusion.SummonEffTG(fparams)

	if chk==0 then
		return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2afil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp))
		or fustg(e,tp,eg,ep,ev,re,r,rp,0)
	end

	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	fustg(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local fparams={handler=c,fusfilter=aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial,SET_RED_EYES),matfilter=Card.IsAbleToDeck,extrafil=s.efil,extraop=Fusion.ShuffleMaterial,extratg=s.tfil}
	local fustg=Fusion.SummonEffTG(fparams)
	local fusop=Fusion.SummonEffOP(fparams)

	local b1=Duel.IsExistingMatchingCard(s.e2afil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=fustg(e,tp,eg,ep,ev,re,r,rp,0)

	if not (b1 or b2) then return end
	
	local op=1
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	elseif (not b1) and b2 then
		op=2
	end

	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e2afil),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)

		if g:GetCount()>0 then
			local c=e:GetHandler()
			local tc=g:GetFirst()
	
			if Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
				local e2a1=Effect.CreateEffect(c)
				e2a1:SetDescription(3206)
				e2a1:SetType(EFFECT_TYPE_SINGLE)
				e2a1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e2a1:SetCode(EFFECT_CANNOT_ATTACK)
				e2a1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2a1)
			end
		end
	elseif op==2 then
		fusop(e,tp,eg,ep,ev,re,r,rp,0)
	end
end
function s.efil(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil)
end
function s.tfil(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end
function s.e3fil1(c,tp)
	return c:IsPreviousControler(tp)
	and c:IsRace(RACE_SPELLCASTER)
	and c:IsMonster()
	and c:IsPreviousLocation(LOCATION_MZONE)
	and c:IsReason(REASON_EFFECT)
end
function s.e3con(e,tp,eg)
	return eg:IsExists(s.e3fil1,1,nil,tp)
end
function s.e3fil2(c)
	return c:IsSetCard(SET_FUSION)
	and c:IsAbleToHand()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e3fil2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
