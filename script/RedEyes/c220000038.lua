-- Red-Eyes Re-Transmigration
local s,id,o=GetID()
-- c220000038
function s.initial_effect(c)
	--[[
	This card can be used to Ritual Summon "Red-Eyes Darkness Chaos Max Dragon" or "Lord of Red Chaos".
	You must also Tribute monsters from your hand or field whose total Levels equal or exceed the Ritual Monster,
	OR Banish 1 "Red-Eyes Black Dragon" you control and 1 monster your opponent controls.
	A Ritual Monster that was Ritual Summoned by this card's effect becomes "Red-Eyes Black Dragon" while on the field,
	also, if you Tributed or banished a monster that was Special Summoned from the Extra Deck for that monster's Ritual Summon,
	it gains 1200 ATK.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	You can reveal this card in your hand, then send 1 "Red-Eyes Black Dragon" from your hand or Deck to the GY;
	add 1 Ritual Monster from your Deck to your hand,
	and if you do, reduce the Level of all Ritual Monsters in your hand by 1 until the End Phase.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	If a Special Summoned monster(s) you control would be destroyed by battle or card effect,
	you can banish this card from your GY instead.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetValue(s.e3val)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil1(c,e,tp)
	return c:IsRitualMonster()
	and (c:IsCode(220000001) or c:IsCode(220000002))
end
function s.e1fil2a(c,e)
	local sc=e:GetHandler()

	return c:IsCanBeRitualMaterial(sc)
	and not c:IsImmuneToEffect(e)
	and c:IsCode(CARD_REDEYES_B_DRAGON)
	and c:IsAbleToRemove()
end
function s.e1fil2b(c,e)
	local sc=e:GetHandler()

	return c:IsCanBeRitualMaterial(sc)
	and not c:IsImmuneToEffect(e)
	and c:IsAbleToRemove()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local rparams={handler=e:GetHandler(),filter=s.e1fil1,lvtype=RITPROC_GREATER,location=LOCATION_HAND,stage2=s.e1evt2}
	local rittg=Ritual.Target(rparams)

	if chk==0 then
		return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e1fil1,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.e1fil2a,tp,LOCATION_MZONE,0,1,nil,e)
		and Duel.IsExistingMatchingCard(s.e1fil2b,tp,0,LOCATION_MZONE,1,nil,e))
		or rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	
	rittg(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp)
	local rparams={handler=e:GetHandler(),filter=s.e1fil1,lvtype=RITPROC_GREATER,location=LOCATION_HAND,stage2=s.e1evt2}
	local rittg=Ritual.Target(rparams)
	local ritop=Ritual.Operation(rparams)

	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 and Duel.IsExistingMatchingCard(s.e1fil2a,tp,LOCATION_MMZONE,0,1,nil,e) then
		ft=1
	end

	local b1=ft>0 and Duel.IsExistingMatchingCard(s.e1fil2a,tp,LOCATION_MZONE,0,1,nil,e) and Duel.IsExistingMatchingCard(s.e1fil2b,tp,0,LOCATION_MZONE,1,nil,e)
	local b2=rittg(e,tp,eg,ep,ev,re,r,rp,0)

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

		local sc=Duel.SelectMatchingCard(tp,s.e1fil1,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		
		if not sc then return end
		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg1=Duel.SelectMatchingCard(tp,s.e1fil2a,tp,LOCATION_MZONE,0,1,1,nil,e)
		local rg2=Duel.SelectMatchingCard(tp,s.e1fil2b,tp,0,LOCATION_MZONE,1,1,nil,e)
		
		if rg1:GetCount()==0 or rg2:GetCount()==0 then return end

		local rg=Group.CreateGroup()
		rg:AddCard(rg1)
		rg:AddCard(rg2)

		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>1 then
			Duel.BreakEffect()

			if Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)==0 then return end
			
			sc:CompleteProcedure()

			local e1b=Effect.CreateEffect(sc)
			e1b:SetType(EFFECT_TYPE_SINGLE)
			e1b:SetCode(EFFECT_CHANGE_CODE)
			e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1b:SetValue(CARD_REDEYES_B_DRAGON)
			e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1b)

			if rg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA) then
				local e1c=Effect.CreateEffect(sc)
				e1c:SetCategory(CATEGORY_ATKCHANGE)
				e1c:SetType(EFFECT_TYPE_SINGLE)
				e1c:SetCode(EFFECT_UPDATE_ATTACK)
				e1c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1c:SetValue(1200)
				e1c:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1c)
			end
		end
	elseif op==2 then
		ritop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.e1evt2(mg,e,tp,eg,ep,ev,re,r,rp,sc)
	local c=e:GetHandler()

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_CHANGE_CODE)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetValue(CARD_REDEYES_B_DRAGON)
	e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc:RegisterEffect(e1b)

	if mg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA) then
		local e1c=Effect.CreateEffect(c)
		e1c:SetCategory(CATEGORY_ATKCHANGE)
		e1c:SetType(EFFECT_TYPE_SINGLE)
		e1c:SetCode(EFFECT_UPDATE_ATTACK)
		e1c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1c:SetValue(1200)
		e1c:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1c)
	end
end
function s.e2fil1(c)
	return c:IsCode(CARD_REDEYES_B_DRAGON)
	and c:IsAbleToGraveAsCost()
end
function s.e2fil2(c)
	return c:IsRitualMonster()
	and c:IsAbleToHand()
end
function s.e2fil3(c)
	return c:IsRitualMonster()
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.e2fil1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	end

	Duel.ConfirmCards(1-tp,c)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local g=Duel.SelectMatchingCard(tp,s.e2fil1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)

	Duel.ShuffleHand(tp)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_DECK,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e2fil2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)

			local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(s.e2fil3,nil)

			local tc=hg:GetFirst()
			for tc in aux.Next(hg) do
				local e2b=Effect.CreateEffect(c)
				e2b:SetType(EFFECT_TYPE_SINGLE)
				e2b:SetCode(EFFECT_UPDATE_LEVEL)
				e2b:SetValue(-1)
				e2b:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2b)
			end
		end
	end
end
function s.e3fil(c,tp)
	return c:IsFaceup()
	and c:IsControler(tp)
	and c:IsLocation(LOCATION_MZONE)
	and c:IsSummonType(SUMMON_TYPE_SPECIAL)
	and not c:IsReason(REASON_REPLACE)
	and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToRemove()
		and eg:IsExists(s.e3fil,1,nil,tp)
	end
	
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.e3val(e,c)
	return s.e3fil(c,e:GetHandlerPlayer())
end
function s.e3evt(e,tp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
