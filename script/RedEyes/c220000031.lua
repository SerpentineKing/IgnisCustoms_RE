-- Thousand Dragon, Breath of Time Magic
local s,id,o=GetID()
-- c220000031
function s.initial_effect(c)
	-- 2 monsters that mention "Dark Time Wizard" with different names
	Fusion.AddProcMixN(c,true,true,s.m1fil1,2)
	c:EnableReviveLimit()
end
local FUSION_SUB_EFF = 511002961
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
function s.m1fil1(c,fc,sumtype,tp,sub,mg,sg)
	return ((not sg)
	or not sg:IsExists(s.m1fil2,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
	and c:ListsCode(CARD_DARK_TIME_WIZARD,fc,sumtype,tp)
end
function s.m1fil2(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code)
	and not c:IsHasEffect(FUSION_SUB_EFF)
end
