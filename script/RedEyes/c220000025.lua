-- Legendary Gambler of Landstar
local s,id,o=GetID()
-- c220000025
function s.initial_effect(c)
	--[[
	[HOPT]
	If a card(s) is added to your opponent's hand (except during the Draw Phase or Damage Step):
	You can reveal this card in your hand;
	Special Summon 1 monster that mentions "Dark Time Wizard" from your hand.
	]]--
	--[[
	[HOPT]
	If this card is sent to the GY, and your opponent has more cards in their hand than you do:
	You can toss a coin and call it. If you call it right, draw until your hand has 5 cards,
	and if you do, show 1 drawn card that mentions "Dark Time Wizard",
	or if you cannot, reveal the drawn cards, and place them on the top of the Deck in the same order.
	If you call it wrong, your opponent can conduct their next Battle Phase twice.
	]]--
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
