-- Jinzo, Black Fullmetal Dragon Armored
local s,id,o=GetID()
-- c220000007
function s.initial_effect(c)
	--[[
	The activation and effect of "Metalmorph" and "Red-Eyes" Traps activated on your field cannot be negated.
	]]--
	
	--[[
	[HOPT]
	If a monster(s) is Tributed from your hand or field (except during the Damage Step):
	You can Special Summon this card from your GY (if it was there when the monster was Tributed) or hand (even if not),
	but banish it when it leaves the field,
	then you can make it become Level 7.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can target 1 "Metalmorph" Trap or "Jinzo" in your GY;
	place that target on the bottom of the Deck,
	then if "Max Metalmorph" is in your GY,
	you can take control of 1 Level 5 or higher face-up monster your opponent controls until your opponent's next End Phase,
	but while it is face-up on your field, it cannot activate its effects.
	]]--
	local e3a1=Effect.CreateEffect(c)
	e3a1:SetDescription(aux.Stringid(id,2))
	e3a1:SetCategory(CATEGORY_TODECK+CATEGORY_CONTROL)
	e3a1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3a1:SetCode(EVENT_SUMMON_SUCCESS)
	e3a1:SetCountLimit(1,{id,1})
	e3a1:SetTarget(s.e3tgt)
	e3a1:SetOperation(s.e3evt)
	c:RegisterEffect(e3a1)

	local e3a2=e3a1:Clone()
	e3a2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3a2)
end
-- Mentions : "Max Metalmorph","Jinzo"
s.listed_names={CARD_MAX_METALMORPH,CARD_JINZO,id}
-- Archetype : Jinzo, Red-Eyes
s.listed_series={SET_JINZO,SET_RED_EYES}
-- Helpers
function s.e2fil(c,tp)
	return c:IsPreviousControler(tp)
	and (c:IsPreviousLocation(LOCATION_MZONE) or (c:IsPreviousLocation(LOCATION_HAND) and c:IsMonster()))
end
function s.e2con(e,tp,eg)
	return eg:IsExists(s.e2fil,1,nil,tp)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((c:IsLocation(LOCATION_GRAVE) and not eg:IsContains(c)) or (c:IsLocation(LOCATION_HAND)))
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e2b1=Effect.CreateEffect(c)
		e2b1:SetType(EFFECT_TYPE_SINGLE)
		e2b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2b1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2b1:SetValue(LOCATION_REMOVED)
		e2b1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e2b1,true)

		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
			Duel.BreakEffect()

			local e2b2=Effect.CreateEffect(c)
			e2b2:SetType(EFFECT_TYPE_SINGLE)
			e2b2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2b2:SetCode(EFFECT_CHANGE_LEVEL)
			e2b2:SetValue(7)
			e2b2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2b2)
		end
	end
end
function s.e3fil1(c)
	return ((c:IsSetCard(SET_METALMORPH) and c:IsTrap()) or c:IsCode(CARD_JINZO))
	and c:IsAbleToDeck()
end
function s.e3fil2(c)
	return c:IsFaceup()
	and c:IsLevelAbove(5)
	and c:IsMonster()
	and c:IsAbleToChangeControler()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e3fil1(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil1,tp,LOCATION_GRAVE,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

	local g=Duel.SelectTarget(tp,s.e3fil1,tp,LOCATION_GRAVE,0,1,1,nil)
	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		local r1 = Duel.IsExistingMatchingCard(s.e3fil2,tp,0,LOCATION_MZONE,1,nil)
		local r2 = Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_MAX_METALMORPH)
		if r1 and r2 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3)) then
			Duel.BreakEffect()

			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)

			local tct=1
			if Duel.IsTurnPlayer(1-tp) and Duel.IsPhase(PHASE_END) then
				tct=3
			elseif Duel.IsTurnPlayer(tp) then
				tct=2
			end

			local g=Duel.SelectMatchingCard(tp,s.e3fil2,tp,0,LOCATION_MZONE,1,1,nil)
			if g:GetCount()>0 and Duel.GetControl(g,tp,PHASE_END,tct) then
				local sc=g:GetFirst()

				local e3b1=Effect.CreateEffect(c)
				e3b1:SetDescription(3302)
				e3b1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e3b1:SetType(EFFECT_TYPE_SINGLE)
				e3b1:SetCode(EFFECT_CANNOT_TRIGGER)
				e3b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
				sc:RegisterEffect(e3b1,true)
			end
		end
	end
end
