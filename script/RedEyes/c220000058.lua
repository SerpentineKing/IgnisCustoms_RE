-- Red-Eyes Black Chaos Dragon
local s,id,o=GetID()
-- c220000058
function s.initial_effect(c)
	-- You can Ritual Summon this card with "Chaos Form".
	c:EnableReviveLimit()
	--[[
	If you Ritual Summon exactly 1 Level 8 Ritual Monster with a card effect that requires the use of monsters,
	this card can be used as the entire Tribute.
	]]--
	Ritual.AddWholeLevelTribute(c,s.e1con)
	--[[
	[H1PT]
	If this card is Ritual Summoned:
	You can target 1 Level 7 or higher Normal Monster in your GY or banishment;
	either add it to your hand or Special Summon it to your opponent's field.
	If you targeted "Red-Eyes Black Dragon" to activate effect,
	you can Special Summon it to your field in face-up Defense Position, instead.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[H1PT]
	If a "Chaos" or "Black Luster Soldier" Ritual Monster(s) is Special Summoned to your field,
	while this card is in your GY (except during the Damage Step):
	You can banish this card, then target 1 of those monsters;
	this turn, that monster can attack all monsters your opponent controls, once each.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfBanish)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local CARD_CHAOS_FORM = 21082832
-- Mentions : "Chaos Form","Red-Eyes Black Dragon"
s.listed_names={CARD_CHAOS_FORM,CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1con(c)
	return c:IsLevel(8)
end
function s.e2con(e)
	local c=e:GetHandler()
	return c:IsRitualSummoned()
end
function s.e2fil(c,e,tp)
	return c:IsLevelAbove(7)
	and c:IsType(TYPE_NORMAL)
	and c:IsMonster()
	and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	or c:IsAbleToHand()
	or (c:IsCode(CARD_REDEYES_B_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)))
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and chkc:IsControler(tp)
		and s.e2fil(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)

	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local b1=tc:IsAbleToHand()
		local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		local b3=tc:IsCode(CARD_REDEYES_B_DRAGON) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0

		if not (b1 or b2 or b3) then return end

		local bsel = {}

		if b1 then
			table.insert(bsel, {b1,aux.Stringid(id,1)})
		end
		if b2 then
			table.insert(bsel, {b1,aux.Stringid(id,2)})
		end
		if b3 then
			table.insert(bsel, {b1,aux.Stringid(id,3)})
		end

		local op=Duel.SelectEffect(tp,table.unpack(bsel))

		if op==1 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		elseif op==2 then
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
		elseif op==3 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
function s.e3fil(c,e,tp)
	return (c:IsSetCard(SET_CHAOS) or c:IsSetCard(SET_BLACK_LUSTER_SOLDIER) or c:IsSetCard(SET_NUMBER_C))
	and c:IsRitualMonster()
	and c:IsControler(tp) 
	and c:IsFaceup()
	and c:IsCanBeEffectTarget(e)
end
function s.e3con(e,tp,eg)
	return eg:IsExists(s.e3fil,1,nil,e,tp)
	and Duel.IsAbleToEnterBP()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return eg:IsContains(chkc)
		and s.e3fil(chkc,e,tp)
	end
	if chk==0 then
		return eg:IsExists(s.e3fil,1,nil,e,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	
	local g=eg:FilterSelect(tp,s.e3fil,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e3b1=Effect.CreateEffect(c)
		e3b1:SetDescription(aux.Stringid(id,5))
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_ATTACK_ALL)
		e3b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3b1:SetValue(1)
		e3b1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3b1)
	end
end
