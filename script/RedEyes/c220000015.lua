-- Red-Eyes Shadow Eclipse Dragon
local s,id,o=GetID()
-- c220000015
function s.initial_effect(c)
	--[[
	[HOPT]
	You can reveal this card in your hand;
	shuffle 1 other card from your hand into the Deck,
	and if you do, Special Summon this card.
	]]--
	--[[
	[HOPT]
	If this card is Special Summoned:
	You can target 1 other monster you control;
	equip 1 Equip Spell, or 1 Normal Trap that has an effect to equip itself, from your Deck or GY to that appropriate monster.
	]]--
	--[[
	[HOPT]
	If this card is destroyed by battle or an opponent's card effect:
	You can banish this card from your GY;
	take 1 card that has "Metalmorph" in its text in your GY or banishment, except this card,
	and either add it to your hand or shuffle it into the Deck.
	]]--
	--[[
	[SOPT]
	Once per turn, if another monster you control is targeted for an attack:
	You can Tribute this card;
	end the Battle Phase,
	also, reduce the attacking monster's ATK to 0 until the start of your opponent’s next turn,
	and if you do, inflict 500 damage to your opponent.
	]]--
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
