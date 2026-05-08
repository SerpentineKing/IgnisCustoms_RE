-- Hermos the Support Dragon
local s,id,o=GetID()
-- c220000013
function s.initial_effect(c)
	--[[
	[H1PT]
	You can send 1 "Red-Eyes" or Warrior monster from your hand or face-up field to the GY;
	Special Summon this card from your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	If this card is Special Summoned:
	You can target 1 face-up monster you control and declare 1 Monster Type;
	that target becomes the declared Type, until the end of this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[H1PT]
	You can Tribute 1 face-up monster;
	Special Summon 1 Fusion Monster that can only be Special Summoned with "The Claw of Hermos"
	from your Extra Deck with the same Type that Tributed monster had on the field.
	(This is treated as a Special Summon by the effect of "The Claw of Hermos").
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.e3cst)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local CARD_THE_CLAW_OF_HERMOS = 46232525
-- Mentions : "The Claw of Hermos"
s.listed_names={CARD_THE_CLAW_OF_HERMOS,id}
-- Helpers
function s.e1fil(c,tp)
	return (c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_WARRIOR))
	and c:IsMonster()
	and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	and c:IsAbleToGraveAsCost()
	and Duel.GetMZoneCount(tp,c)>0
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e2fil(c,e,tp)
	return c:IsFaceup()
	and c:IsControler(tp)
	and c:IsMonster()
	and c:IsCanBeEffectTarget(e)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and s.e2fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	
	local g=Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_MZONE,0,1,1,nil,e,tp)

	local dval=Duel.AnnounceRace(tp,1,RACE_ALL&~g:GetFirst():GetRace())
	e:SetLabel(dval)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e2b1=Effect.CreateEffect(c)
		e2b1:SetType(EFFECT_TYPE_SINGLE)
		e2b1:SetCode(EFFECT_CHANGE_RACE)
		e2b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2b1:SetValue(e:GetLabel())
		e2b1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2b1)
	end
end
function s.e3fil1(c,e,tp)
	return c:IsFaceup()
	and c:IsMonster()
	and c:IsReleasable()
	and Duel.IsExistingMatchingCard(s.e3fil2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRace())
end
function s.e3fil2(c,e,tp,rval)
	return c:IsType(TYPE_FUSION)
	and c:IsMonster()
	and c.material_race
	and c:IsRace(rval)
	and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,s.e3fil1,1,false,nil,nil,e,tp)
	end
	
	local sg=Duel.SelectReleaseGroupCost(tp,s.e3fil1,1,1,false,nil,nil,e,tp)

	e:SetLabel(sg:GetFirst():GetRace())
	
	Duel.Release(sg,REASON_COST)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil2,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetLabel())
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	
	local g=Duel.GetMatchingGroup(s.e3fil2,tp,LOCATION_EXTRA,0,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
