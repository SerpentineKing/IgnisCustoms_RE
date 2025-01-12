-- Hermos the Support Dragon
local s,id,o=GetID()
-- c220000013
function s.initial_effect(c)
	--[[
	[HOPT]
	You can send 1 Dragon monster, or 1 Spell/Trap that has “Red-Eyes” in its text, from your hand or face-up field to the GY;
	Special Summon this card from your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During your Main Phase:
	You can Fusion Summon 1 Fusion Monster from your Extra Deck,
	using monsters from your hand and/or field as material, including a Dragon monster.
	]]--
	local params = {nil,nil,function(e,tp,mg) return nil,s.e2fil end}

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is sent from the field to the GY: You can banish this card from your GY; apply the following effect.
	•
	Show 1 Fusion Monster that must be Special Summoned with “The Claw of Hermos” from your Extra Deck, and if you do,
	send 1 monster from your hand or field to the GY with same Type as the shown monster (if that card is Set, reveal it),
	then Special Summon the shown monster from your Extra Deck.
	(This is treated as a Special Summon by the effect of “The Claw of Hermos”.)
	]]--
	-- FIX [Condition]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "The Claw of Hermos"
s.listed_names={46232525,id}
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1fil(c,tp)
	return ((c:IsMonster() and c:IsRace(RACE_DRAGON))
	or ((c:IsSetCard(SET_RED_EYES)
	or c:IsSetCard(0xfe1)
	or c:IsCode(36262024)
	or c:IsCode(93969023)
	or c:IsCode(66574418)
	or c:IsCode(11901678)
	or c:IsCode(45349196)
	or c:IsCode(90660762)
	or c:IsCode(19025379)
	or c:IsCode(71408082)
	or c:IsCode(71408082)
	or c:IsCode(32566831)
	or c:IsCode(52684508)
	or c:IsCode(18803791))
	and c:IsSpellTrap()))
	and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	and c:IsAbleToGraveAsCost()
	and Duel.GetMZoneCount(tp,c)>0
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e2fil(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end
function s.e3fil1(c,e,tp)
	if c.material_race then
		Debug.ShowHint("FILTER RUN")
	end
	return c:IsType(TYPE_FUSION)
	and c.material_race
	and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	-- and Duel.IsExistingMatchingCard(s.e3fil2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,c.material_race)
	-- and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.e3fil2(c,mr)
	return c:IsMonster()
	and mr==c:GetRace()
end
function s.e3con(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil1,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.e3evt(e,tp)
	Debug.ShowHint("EVENT FIRED")
	--[[
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)

	local g=Duel.SelectMatchingCard(tp,s.e3fil1,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local sc=g:GetFirst()
	local fg=Duel.SelectMatchingCard(tp,s.e3fil2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,sc.material_race)

	local tc=fg:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		if tc:IsOnField() and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
		end
		Duel.SendtoGrave(tc,REASON_EFFECT)
		
		if not tc:IsLocation(LOCATION_GRAVE) then return end
		Duel.BreakEffect()

		Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
	]]--
end
