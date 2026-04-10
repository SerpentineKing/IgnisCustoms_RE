-- Red-Eyes Re-Transmigration
local s,id,o=GetID()
-- c220000038
function s.initial_effect(c)
	-- [Activation]
	--[[
	This card can be used to Ritual Summon any "Red-Eyes" Ritual Monster from your hand or GY.
	You must also Tribute monsters from your hand and/or field
	whose total Levels equal or exceed the Level of the Ritual Monster.
	If Summoning "Lord of the Red Chaos" this way,
	you can also banish monsters from your opponent's GY as monsters required for the Ritual Summon.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PD]
	When an opponent's monster declares a direct attack,
	while your LP are 2000 or less and this card is in your GY:
	You can add this card from your GY to your hand,
	and if you do, negate that attack.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
local CARD_LORD_OF_THE_RED_CHAOS = 220000002
-- Mentions : "Lord of the Red Chaos"
s.listed_names={CARD_LORD_OF_THE_RED_CHAOS,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1sfil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsRitualMonster()
end
function s.e1s1fil(c)
	return s.e1sfil(c)
	and c:IsCode(CARD_LORD_OF_THE_RED_CHAOS)
end
function s.e1s2fil(c)
	return s.e1sfil(c)
	and not c:IsCode(CARD_LORD_OF_THE_RED_CHAOS)
end
function s.e1mxfil(c,e,tp)
	local sc=e:GetHandler()

	return c:IsMonster()
	and c:IsCanBeRitualMaterial(sc)
	and c:IsLevelAbove(1)
	and not Duel.IsPlayerAffectedByEffect(c:GetControler(),CARD_SPIRIT_ELIMINATION)
	and c:IsAbleToRemove()
end
function s.e1xfil(e,tp,mg)
	if not Duel.IsPlayerCanRelease(tp) then return nil end

	return Duel.GetMatchingGroup(s.e1mxfil,tp,0,LOCATION_GRAVE,nil,e,tp)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	local rparams1={handler=c,filter=s.e1s1fil,extrafil=s.e1xfil,lvtype=RITPROC_GREATER,location=LOCATION_HAND+LOCATION_GRAVE}
	local rittg1=Ritual.Target(rparams1)

	local rparams2={handler=c,filter=s.e1s2fil,lvtype=RITPROC_GREATER,location=LOCATION_HAND+LOCATION_GRAVE}
	local rittg2=Ritual.Target(rparams2)

	if chk==0 then
		return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e1sfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil))
		or rittg1(e,tp,eg,ep,ev,re,r,rp,chk)
		or rittg2(e,tp,eg,ep,ev,re,r,rp,chk)
	end

	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)

	rittg1(e,tp,eg,ep,ev,re,r,rp,chk)
	rittg2(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local rparams1={handler=c,filter=s.e1s1fil,extrafil=s.e1xfil,lvtype=RITPROC_GREATER,location=LOCATION_HAND+LOCATION_GRAVE}
	local rittg1=Ritual.Target(rparams1)
	local ritop1=Ritual.Operation(rparams1)

	local rparams2={handler=c,filter=s.e1s2fil,lvtype=RITPROC_GREATER,location=LOCATION_HAND+LOCATION_GRAVE}
	local rittg2=Ritual.Target(rparams2)
	local ritop2=Ritual.Operation(rparams2)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local sc=Duel.SelectMatchingCard(tp,s.e1sfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil):GetFirst()

	if not sc then return end

	if sc:GetCode()==CARD_LORD_OF_THE_RED_CHAOS then
		ritop1(e,tp,eg,ep,ev,re,r,rp,0)
	else
		ritop2(e,tp,eg,ep,ev,re,r,rp,0)
	end
end
function s.e2con(e,tp)
	return Duel.GetAttacker():IsControler(1-tp)
	and Duel.GetAttackTarget()==nil
	and Duel.GetLP(tp)<=2000
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return c:IsAbleToHand()
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
			Duel.NegateAttack()
		end
	end
end
