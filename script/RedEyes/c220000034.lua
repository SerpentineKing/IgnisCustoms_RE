-- Old Swordmaster of the Flame
local s,id,o=GetID()
-- c220000034
function s.initial_effect(c)
	-- "Flame Swordsman" + 1 monster that mentions "Dark Time Wizard"
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
end
-- Mentions : "Flame Swordsman","Dark Time Wizard"
s.listed_names={CARD_FLAME_SWORDSMAN,CARD_DARK_TIME_WIZARD,id}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsCode(CARD_FLAME_SWORDSMAN)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:ListsCode(CARD_DARK_TIME_WIZARD)
end
