-- Black Dragon’s Soul
local s,id,o=GetID()
-- c220000017
function s.initial_effect(c)
	--[[
	[SOPT]
	Once per turn:
	You can place 1 “Red-Eyes Black Dragon”, or 1 card that mentions it, from your hand, Deck, or GY on top of the Deck, except “Black Dragon’s Soul”.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During your Main Phase:
	You can banish this card from your GY;
	draw cards equal to the number of “Red-Eyes Black Dragon” with different original names on the field and in the GYs.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Mentions : "Red-Eyes Black Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,id}
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1fil(c,ct)
	return not c:IsCode(id)
	and (c:IsCode(CARD_REDEYES_B_DRAGON) or c:ListsCode(CARD_REDEYES_B_DRAGON))
	and ((c:IsLocation(LOCATION_DECK) and ct>1) or (not c:IsLocation(LOCATION_DECK) and c:IsAbleToDeck()))
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.e1evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))

	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e1fil),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,ct):GetFirst()
	
	if tc then
		if tc:IsLocation(LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
			Duel.MoveToDeckTop(tc)
		else 
			Duel.HintSelection(tc,true)
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if not tc:IsLocation(LOCATION_EXTRA) then
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
function s.e2fil(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
	and c:IsCode(CARD_REDEYES_B_DRAGON)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil):GetClassCount(Card.Card.GetOriginalCodeRule)
	if chk==0 then
		return ct>0
		and Duel.IsPlayerCanDraw(tp,ct)
	end
	
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.e2evt(e,tp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil):GetClassCount(Card.Card.GetOriginalCodeRule)
	Duel.Draw(p,ct,REASON_EFFECT)
end
