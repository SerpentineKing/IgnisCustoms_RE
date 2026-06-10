-- Harpie Lady the Red-Eyes Cyber Nightingale
local s,id,o=GetID()
-- c220000022
function s.initial_effect(c)
	--[[
	This card's name becomes "Harpie Lady" while on the field or in the GY,
	but is still treated as a "Red-Eyes" card.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_HARPIE_LADY)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	If this card is Normal or Special Summoned:
	You can discard 1 card;
	place 1 "Return of the Red-Eyes" from your hand, Deck, or GY face-up in your Spell & Trap Zone,
	then if you discarded a Normal Monster to activate this effect,
	you can destroy all face-up Spells your opponent controls.
	]]--
	local e2a1=Effect.CreateEffect(c)
	e2a1:SetDescription(aux.Stringid(id,0))
	e2a1:SetCategory(CATEGORY_DESTROY)
	e2a1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a1:SetCode(EVENT_SUMMON_SUCCESS)
	e2a1:SetProperty(EFFECT_FLAG_DELAY)
	e2a1:SetCountLimit(1,{id,0})
	e2a1:SetCost(s.e2cst)
	e2a1:SetTarget(s.e2tgt)
	e2a1:SetOperation(s.e2evt)
	c:RegisterEffect(e2a1)
	
	local e2a2=e2a1:Clone()
	e2a2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2a2)
	--[[
	[H1PT]
	You can target 1 Level 5 or higher "Harpie" or "Red-Eyes" monster you control;
	until the end of this turn, the Level of that monster or this card becomes the Level of the other,
	also you cannot declare an attack for the rest of this turn, except with DARK or WIND monsters.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local RESETS_END_PHASE = RESET_PHASE+PHASE_END
local CARD_RETURN_OF_THE_RED_EYES = 39387565
-- Mentions : "Harpie Lady","Return of the Red-Eyes"
s.listed_names={CARD_HARPIE_LADY,CARD_RETURN_OF_THE_RED_EYES,id}
-- Archetype : Harpie, Red-Eyes
s.listed_series={SET_HARPIE,SET_RED_EYES}
-- Helpers
function s.e2fil1(c)
	return c:IsType(TYPE_NORMAL)
	and c:IsMonster()
	and c:IsDiscardable()
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	e:SetLabel(g:GetFirst():IsType(TYPE_NORMAL) and 1 or 0)

	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.e2fil2(c,tp)
	return c:IsCode(CARD_RETURN_OF_THE_RED_EYES)
	and not c:IsForbidden()
	and c:CheckUniqueOnField(tp)
end
function s.e2fil3(c,e)
	return c:IsFaceup()
	and c:IsSpell()
	and c:IsDestructable(e)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	end
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e2fil2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)

		local g=Duel.GetMatchingGroup(s.e2fil3,tp,0,LOCATION_ONFIELD,nil,e)
		if e:GetLabel()==1 and g:GetCount()>0 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
			Duel.BreakEffect()

			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.e3fil1(c,lv)
	return c:IsLevelAbove(5)
	and (c:IsSetCard(SET_HARPIE) or c:IsSetCard(SET_RED_EYES))
	and c:IsMonster()
	and c:IsFaceup()
	and not c:IsLevel(lv)
end
function s.e3fil2(e,c)
	return not (c:IsAttribute(ATTRIBUTE_DARK)
	or c:IsAttribute(ATTRIBUTE_WIND))
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	local lv=c:GetLevel()
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and s.e3fil1(chkc,lv)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil1,tp,LOCATION_MZONE,0,1,c,lv)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.e3fil1,tp,LOCATION_MZONE,0,1,1,c,lv)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsLevel(c:GetLevel()) then
		local g=Group.FromCards(c,tc)
		
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))

		local sg=g:Select(tp,1,1,nil)
		local sc=(g-sg):GetFirst()
		
		local e3b1=Effect.CreateEffect(c)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_CHANGE_LEVEL)
		e3b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3b1:SetValue(sg:GetFirst():GetLevel())
		e3b1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e3b1)
	end

	local e3b2=Effect.CreateEffect(c)
	e3b2:SetType(EFFECT_TYPE_FIELD)
	e3b2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3b2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3b2:SetTargetRange(LOCATION_MZONE,0)
	e3b2:SetTarget(s.e3fil2)
	e3b2:SetReset(RESETS_END_PHASE)
	Duel.RegisterEffect(e3b2,tp)

	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,4),nil)
end
