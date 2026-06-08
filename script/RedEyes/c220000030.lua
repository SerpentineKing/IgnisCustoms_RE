-- Magical Arm Capture
local s,id,o=GetID()
-- c220000030
function s.initial_effect(c)
	--[[
	[H1PT]
	If you control a card that mentions "Dark Time Wizard":
	You can Tribute any number of monsters, then target an equal number of face-up monsters your opponent controls;
	take control of them until the End Phase of the next turn,
	but while you control them, you cannot activate their effects, they cannot declare an attack,
	also they are also treated as monsters that mention "Dark Time Wizard".
	]]--
	--[[
	[H1PT]
	You can banish this card from your GY;
	reveal any number of cards in your hand, including a card that mentions "Dark Time Wizard",
	and place them on the bottom of the Deck in any order, then draw that many cards.
	]]--
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
