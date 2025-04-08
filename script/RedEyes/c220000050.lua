-- Thousand Dragon, Breath of Time Magic
local s,id,o=GetID()
-- c220000050
function s.initial_effect(c)
	-- "Time Wizard" + 1 Level 3 or 4 Dragon monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
end
-- Mentions : "Time Wizard"
s.listed_names={71625222,id}
-- Archetype : N/A
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsCode(71625222)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON)
	and (c:IsLevel(3) or c:IsLevel(4))
end
