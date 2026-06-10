-- Red-Eyes Dark Flare Fusion
local s,id,o=GetID()
-- c220000022
function s.initial_effect(c)
	-- [Activation]
	--[[
	[H1PT]
	Fusion Summon 1 DARK or FIRE Fusion Monster from your Extra Deck,
	using monsters from your hand and/or field as material, including a Normal Monster,
	also, you cannot Special Summon monsters from the Extra Deck for the rest of this turn,
	except Fusion or Xyz Monsters.
	If Summoning a Fusion Monster that mentions "Red-Eyes Black Dragon" as material this way,
	you can also use 1 monster in your Deck as material.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	If this Set card in its owner's control is destroyed by an opponent's card effect and sent to the GY:
	You can Tribute 1 monster your opponent controls, and if you do, inflict 1200 damage to your opponent.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	-- This card's name becomes "Red-Eyes Fusion" while in the GY.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetValue(s.e3val)
	c:RegisterEffect(e3)
end
local RESETS_END_PHASE = RESET_PHASE+PHASE_END
local CARD_RED_EYES_FUSION = 6172122
-- Mentions : "Red-Eyes Black Dragon","Red-Eyes Fusion"
s.listed_names={CARD_REDEYES_B_DRAGON,CARD_RED_EYES_FUSION,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1sfil(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_FIRE))
end
function s.e1sxfil(tp,sg,sc)
	return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
	and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.e1mxfil(c,e,tp)
	local sc=e:GetHandler()

	return c:IsCanBeFusionMaterial(sc)
	and c:IsAbleToGrave()
	and sc:ListsCodeAsMaterial(CARD_REDEYES_B_DRAGON)
end
function s.e1xfil(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(s.e1mxfil,tp,LOCATION_DECK,0,nil,e,tp),s.e1sxfil
end
function s.e1xtgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end 
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local fparams={handler=c,fusfilter=s.e1sfil,extrafil=s.e1xfil,extratg=s.e1xtgt}
	local fustg=Fusion.SummonEffTG(fparams)

	if chk==0 then
		return fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	end

	fustg(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local fparams={handler=c,fusfilter=s.e1sfil,extrafil=s.e1xfil,extratg=s.e1xtgt}
	local fustg=Fusion.SummonEffTG(fparams)
	local fusop=Fusion.SummonEffOP(fparams)

	local cond=fustg(e,tp,eg,ep,ev,re,r,rp,0)
	if cond then
		fusop(e,tp,eg,ep,ev,re,r,rp,0)
	end

	local c=e:GetHandler()

	local e1b1=Effect.CreateEffect(c)
	e1b1:SetDescription(aux.Stringid(id,1))
	e1b1:SetType(EFFECT_TYPE_FIELD)
	e1b1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1b1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1b1:SetTargetRange(1,0)
	e1b1:SetTarget(s.e1lim)
	e1b1:SetReset(RESETS_END_PHASE)
	Duel.RegisterEffect(e1b1,tp)

	aux.addTempLizardCheck(c,tp,s.e1zfil)
end
function s.e1lim(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ))
	and c:IsLocation(LOCATION_EXTRA)
end
function s.e1zfil(e,c)
	return not (c:IsOriginalType(TYPE_FUSION) or c:IsOriginalType(TYPE_XYZ))
end
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	return c:IsPreviousPosition(POS_FACEDOWN)
	and c:IsPreviousControler(tp)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
	and c:IsReason(REASON_DESTROY)
	and rp==1-tp
	and c:IsReason(REASON_EFFECT)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil)
	end

	local dmg = 1200
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.Release(g,REASON_EFFECT)>0 then
			local dmg = 1200
			Duel.Damage(1-tp,dmg,REASON_EFFECT)
		end
	end
end
function s.e3val()
	return CARD_RED_EYES_FUSION
end
