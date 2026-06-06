-- Thousand Dragon, Breath of Time Magic
local s,id,o=GetID()
-- c220000031
function s.initial_effect(c)
	-- 2 monsters that mention "Dark Time Wizard" with different names
	-- Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
