-- Black Dragon’s Mage
local s,id,o=GetID()
-- c220000016
function s.initial_effect(c)
	-- This card’s name becomes “Dark Magician” while in the hand, GY, or on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(CARD_DARK_MAGICIAN)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is in your hand or on the field:
	You can send 1 “Red-Eyes Black Dragon” from your hand or Deck to the GY,
	then apply 1 of the following effects, depending on where this card was at activation.
	•
	Hand: Special Summon this card.
	•
	Field: This turn, if this card attacks a Defense Position monster, inflict piercing battle damage,
	also, banish any monster destroyed by battle with this card.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetType(EFFECT_TYPE_IGNITION)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCountLimit(1,{id,1})
	e2b:SetTarget(s.e2btgt)
	e2b:SetOperation(s.e2bevt)
	c:RegisterEffect(e2b)
	--[[
	[HOPT]
	You can send up to 2 Spells/Traps from your hand and/or field to the GY;
	draw that many cards.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.e3cst)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	You can Tribute this card;
	Special Summon 1 “Red-Eyes” monster from your hand or Deck, except “Black Dragon’s Mage”.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.e4cst)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
-- Mentions : "Dark Magician","Red-Eyes Black Dragon"
s.listed_names={CARD_DARK_MAGICIAN,CARD_REDEYES_B_DRAGON,id}
-- Archetype : Red-Eyes, Dark Magician
s.listed_series={SET_RED_EYES,SET_DARK_MAGICIAN}
-- Helpers
function s.e2fil(c)
	return c:IsCode(CARD_REDEYES_B_DRAGON)
	and c:IsAbleToGrave()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,c)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local tc=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,c):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e2btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.e2bevt(e,tp)
	local c=e:GetHandler()
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local tc=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,c):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		local e2b1=Effect.CreateEffect(c)
		e2b1:SetDescription(3208)
		e2b1:SetType(EFFECT_TYPE_SINGLE)
		e2b1:SetCode(EFFECT_PIERCE)
		e2b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2b1)

		local e2b2=Effect.CreateEffect(c)
		e2b2:SetType(EFFECT_TYPE_SINGLE)
		e2b2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
		e2b2:SetValue(LOCATION_REMOVED)
		e2b2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2b2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2b2)
	end
end
function s.e3fil(c)
	return c:IsSpellTrap()
	and c:IsAbleToGraveAsCost()
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
	end
	
	local ft=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	local ct=math.min(ft,g:GetCount())

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	
	local sg=g:Select(tp,1,math.min(ct,2),nil)
	e:SetLabel(sg:GetCount())

	Duel.SendtoGrave(sg,REASON_COST)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	
	local ct=e:GetLabel()
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.e3evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReleasable()
	end

	Duel.Release(c,REASON_COST)
end
function s.e4fil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end

	if chk==0 then
		return ft>0
		and Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_DECK)
end
function s.e4evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e4fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
