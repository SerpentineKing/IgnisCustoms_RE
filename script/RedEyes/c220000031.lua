-- Primordial Dark Sage
local s,id,o=GetID()
-- c220000031
function s.initial_effect(c)
	-- "Dark Magician" + 1 monster that mentions "Dark Time Wizard"
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
end
-- Mentions : "Dark Magician","Dark Time Wizard"
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_TIME_WIZARD,id}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsCode(CARD_DARK_MAGICIAN)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:ListsCode(CARD_DARK_TIME_WIZARD)
end
