-- Gilford the Blazing Red Lightning
local s,id,o=GetID()
-- c220000030
function s.initial_effect(c)
	-- 3 monsters with different types, including a monster that mentions "Dark Time Wizard"
	-- Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
