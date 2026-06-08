-- Gilford the Thunderous Lightning
local s,id,o=GetID()
-- c220000032
function s.initial_effect(c)
	-- 3 monsters with different Types, including a monster that mentions "Dark Time Wizard"
	Fusion.AddProcMixN(c,true,true,s.m1fil,3)
	c:EnableReviveLimit()
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
function s.m1fil(c,fc,sumtype,sp,sub,mg,sg)
	return ((not sg or sg:FilterCount(aux.TRUE,c)==0)
	or not sg:IsExists(Card.IsRace,1,c,c:GetRace(),fc,sumtype,sp))
	and ((c:ListsCode(CARD_DARK_TIME_WIZARD,fc,sumtype,sp) and not sg:IsExists(Card.ListsCode,1,c,CARD_DARK_TIME_WIZARD,fc,sumtype,sp))
	or sg:IsExists(Card.ListsCode,1,c,CARD_DARK_TIME_WIZARD,fc,sumtype,sp))
end
