-- Jinzo, Black Dragon Armored
local s,id,o=GetID()
-- c220000007
function s.initial_effect(c)
	-- 1 Level 7 "Red-Eyes" monster + 1 DARK Machine monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- Unaffected by Trap effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.e1fil)
	c:RegisterEffect(e1)
	-- Trap Cards, and their effects on your opponent's field, cannot be activated.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_HAND+LOCATION_SZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	c:RegisterEffect(e2)
	-- Negate all Trap effects on your opponent's field.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_SZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	c:RegisterEffect(e5)
	--[[
	[SOPT]
	Once per turn: You can destroy as many face-up Traps on your opponent's field as possible,
	and if you do, inflict 400 damage to your opponent for each card destroyed by this effect.
	]]--
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.e6tgt)
	e6:SetOperation(s.e6evt)
	c:RegisterEffect(e6)
	--[[
	[HOPT]
	You can Set 1 Trap from your Deck or GY that has "Red-Eyes" in its text.
	It can be activated this turn.
	]]--
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,{id,0})
	e7:SetTarget(s.e7tgt)
	e7:SetOperation(s.e7evt)
	c:RegisterEffect(e7)
	--[[
	[HOPT]
	If this card is sent from the field to the GY:
	You can Special Summon 1 Dragon or Machine monster from your hand, Deck, or GY, except "Jinzo, Black Dragon Armored".
	]]--
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCountLimit(1,{id,1})
	e8:SetCondition(s.e8con)
	e8:SetTarget(s.e8tgt)
	e8:SetOperation(s.e8evt)
	c:RegisterEffect(e8)

	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
-- Archetype : Jinzo
s.listed_series={SET_JINZO,0xfe1}
-- Red-Eyes Fusion
s.material_setcode=SET_RED_EYES
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevel(7)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_MACHINE)
	and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.e1fil(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
function s.e4evt(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) and rp==(1-tp) then
		Duel.NegateEffect(ev)
	end
end
function s.e6fil(c)
	return c:IsFaceup()
	and c:IsTrap()
end
function s.e6tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e6fil,tp,0,LOCATION_ONFIELD,1,nil)
	end

	local g=Duel.GetMatchingGroup(s.e6fil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*400)
end
function s.e6evt(e,tp)
	local sg=Duel.GetMatchingGroup(s.e6fil,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
function s.e7fil(c)
	return (c:IsSetCard(SET_RED_EYES)
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
	and c:IsTrap()
	and c:IsSSetable()
end
function s.e7tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e7fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
end
function s.e7evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.e7fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 and Duel.SSet(tp,g)>0 then
		local c=e:GetHandler()
		local tc=g:GetFirst()

		local e7b=Effect.CreateEffect(c)
		e7b:SetType(EFFECT_TYPE_SINGLE)
		e7b:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e7b:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e7b:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e7b)
	end
end
function s.e8con(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e8fil(c,e,tp)
	return (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_MACHINE))
	and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e8tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e8fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.e8evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e8fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
