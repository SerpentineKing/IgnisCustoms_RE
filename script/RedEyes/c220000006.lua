-- Legendary Fisherman with Eyes of Red
local s,id,o=GetID()
-- c220000006
function s.initial_effect(c)
	--[[
	A Ritual Monster that was Ritual Summoned using this card as material
	is unaffected by your opponent's Spell effects.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.e1con)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	You can discard this card;
	add 1 Ritual Spell that has "Red-Eyes" in its text,
	or 1 Level 8 or lower Dragon Ritual Monster (DARK or FIRE), from your Deck to your hand.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(Cost.SelfDiscard)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[H1PT]
	If this card is in your GY:
	You can target 1 Spell/Trap on each field;
	Special Summon this card (but banish it when it leaves the field),
	and if you do, return those targets to the hand,
	then if you targeted a card whose name was "Umi" while on the field with this effect,
	until the end of the next turn, your opponent cannot activate cards,
	or the effects of cards, with the same original name as any card returned to their hand by this effect.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local RESETS_ON_LEAVE = RESET_EVENT+RESETS_STANDARD
local RESETS_END_PHASE = RESET_PHASE+PHASE_END
local CARD_DARK_DRAGON_RITUAL = 18803791
-- Mentions : "Umi"
s.listed_names={CARD_UMI,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1con(e,tp,eg,ep,ev,re,r)
	return r==REASON_RITUAL
end
function s.e1fil(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
	and te:IsSpellEffect()
end
function s.e1evt(e,tp,eg)
	local c=e:GetHandler()
	for rc in eg:Iter() do
		if rc:GetFlagEffect(id)==0 then
			local e1b1=Effect.CreateEffect(c)
			e1b1:SetDescription(3102)
			e1b1:SetType(EFFECT_TYPE_SINGLE)
			e1b1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1b1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1b1:SetRange(LOCATION_MZONE)
			e1b1:SetValue(s.e1fil)
			e1b1:SetReset(RESETS_ON_LEAVE)
			rc:RegisterEffect(e1b1,true)
			rc:RegisterFlagEffect(id,RESETS_ON_LEAVE,0,1)
		end
	end
end
function s.e2fil(c)
	return (c:IsCode(18803791) or (c:IsRitualSpell() and c:IsSetCard(SET_RED_EYES)))
	or (c:IsLevelBelow(8) and c:IsRace(RACE_DRAGON) and c:IsRitualMonster() and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_FIRE)))
	and c:IsAbleToHand()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e3fil(c)
	return c:IsSpellTrap()
	and c:IsAbleToHand()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return false
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(s.e3fil,tp,0,LOCATION_ONFIELD,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_ONFIELD,0,1,1,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,s.e3fil,tp,0,LOCATION_ONFIELD,1,1,nil)

	g1:Merge(g2)
	e:SetLabel(0)
	for tc in g1:Iter() do
		if tc:GetCode() == CARD_UMI then
			e:SetLabel(1)
		end
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
function s.e3lim(e,re,tp)
	return re:GetHandler():IsOriginalCode(e:GetLabel())
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)

	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e3b1=Effect.CreateEffect(c)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3b1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3b1:SetValue(LOCATION_REMOVED)
		e3b1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e3b1,true)

		local tg=g:Filter(Card.IsRelateToEffect,nil,e)
		if tg:GetCount()>0 then
			if Duel.SendtoHand(tg,nil,REASON_EFFECT)>0 and e:GetLabel()==1 then
				Duel.BreakEffect()

				for tc in g:Iter() do
					if tc:IsLocation(LOCATION_HAND) and tc:IsControler(1-tp) then
						local e3b2=Effect.CreateEffect(c)
						e3b2:SetType(EFFECT_TYPE_FIELD)
						e3b2:SetCode(EFFECT_CANNOT_ACTIVATE)
						e3b2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
						e3b2:SetTargetRange(0,1)
						e3b2:SetValue(s.e3lim)
						e3b2:SetLabel(tc:GetCode())
						e3b2:SetReset(RESETS_END_PHASE,2)
						Duel.RegisterEffect(e3b2,tp)
					end
				end
			end
		end
	end
end
