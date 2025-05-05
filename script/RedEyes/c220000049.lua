-- Time Magic Fusion
local s,id,o=GetID()
-- c220000049
function s.initial_effect(c)
	-- Equip only to a "Time Wizard" monster that is equipped with a "Red-Eyes" monster.
	aux.AddEquipProcedure(c,nil,s.eqfil)
	-- The equipped monster gains 500 ATK.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- If this equipped monster would be destroyed by battle or card effect, you can destroy this card instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.e2tgt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	While this card is equipped to a Fusion Monster you control:
	You can send this card and the equipped monster to the GY,
	and if you do, Special Summon 1 "Thousand Dragon" or 1 Fusion Monster that mentions it from your Extra Deck.
	(This is treated as a Fusion Summon.)
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "Thousand Dragon"
s.listed_names={41462083,id}
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.eqfil(c)
	local eqg=c:GetEquipGroup()

	return (c:IsCode(71625222)
	or c:IsCode(26273196)
	or c:IsCode(220000024))
	and (eqg and eqg:IsExists(s.eqfil2,1,nil))
end
function s.eqfil2(c)
	return c:IsSetCard(SET_RED_EYES)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()

	if chk==0 then
		return ec:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not ec:IsReason(REASON_REPLACE)
		and c:IsDestructable()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
	end

	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Destroy(c,REASON_EFFECT)
		return true
	else
		return false
	end
end
function s.e3con(e,tp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsType(TYPE_FUSION) and ec:IsControler(tp)
end
function s.e3fil(c,e,tp,mc)
	return (c:IsCode(41462083) or (c:IsType(TYPE_FUSION) and c:ListsCode(41462083)))
	and Duel.GetLocationCountFromEx(tp,tp,mc,c)
	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
	and c:CheckFusionMaterial()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	
	if chk==0 then
		return c:IsAbleToGrave()
		and ec:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_EXTRA,0,1,nil,e,tp,ec)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,Group.FromCards(c,ec),2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.e3evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()

	if not (c:IsRelateToEffect(e) and ec) then return end
	
	local g=Group.FromCards(c,ec)
	
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 or g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	
	if not sc then return end
	
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end
