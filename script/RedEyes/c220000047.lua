-- Red-Eyes Harpie Lady, Nightmare in the Darkness
local s,id,o=GetID()
-- c220000047
function s.initial_effect(c)
	-- If you control a "Red-Eyes" monster, you can Normal Summon this card without Tributing.
	--[[
	[SOPT]
	Once per turn, when this card destroys an opponent's monster by battle:
	Your opponent must discard 1 card.
	]]--
	--[[
	If this card is destroyed by battle or card effect:
	You can return 1 card on the field to the hand, and if you do, discard 1 card.
	]]--
	--[[
	[HOPT]
	During your Main Phase: You can activate 1 of these effects.
	•
	Destroy as many Spells/Traps your opponent controls as possible,
	and if you do, inflict 500 damage to your opponent for each card destroyed by this effect.
	•
	Destroy as many monsters your opponent controls as possible,
	and if you do, gain LP equal to half the combined ATK of those destroyed monsters.
	]]--
end
-- Archetype : Red-Eyes, Harpie
s.listed_series={SET_RED_EYES,SET_HARPIE}
-- Helpers
