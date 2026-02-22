-- Red-Eyes Mechanization
local s,id,o=GetID()
-- c220000029
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can add 1 "Incoming Machine!" or "Dragon Nails" from your Deck or banishment to your hand.
	]]--
	local e1a1=Effect.CreateEffect(c)
	e1a1:SetDescription(aux.Stringid(id,0))
	e1a1:SetType(EFFECT_TYPE_ACTIVATE)
	e1a1:SetCode(EVENT_FREE_CHAIN)
	e1a1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1a1)

	local e1a2=e1a1:Clone()
	e1a2:SetDescription(aux.Stringid(id,1))
	e1a2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a2:SetCondition(s.e1con)
	e1a2:SetOperation(s.e1evt)
	c:RegisterEffect(e1a2)
	--[[
	Traps with an effect that equip themselves to a monster in your Spell & Trap Zone cannot be banished by your opponent's card effects,
	also your opponent cannot target them with card effects.
	]]--
	local e2a1=Effect.CreateEffect(c)
	e2a1:SetType(EFFECT_TYPE_FIELD)
	e2a1:SetCode(EFFECT_CANNOT_REMOVE)
	e2a1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a1:SetRange(LOCATION_SZONE)
	e2a1:SetTargetRange(0,1)
	e2a1:SetTarget(s.e2tgt)
	c:RegisterEffect(e2a1)

	local e2a2=e2a1:Clone()
	e2a2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2a2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2a2:SetValue(aux.tgoval)
	c:RegisterEffect(e2a2)
	-- The first time each "Red-Eyes" monster you control would be destroyed by battle each turn, it is not destroyed.
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetTargetRange(LOCATION_MZONE,0)
	e2b:SetTarget(s.e2btgt)
	e2b:SetValue(s.e2bval)
	c:RegisterEffect(e2b)
	--[[
	[HOPT]
	When your "Red-Eyes" or Level 5 or higher Machine monster is targeted for an attack:
	You can target 1 Normal Spell/Trap in your opponent's GY;
	Set it to your field.
	While a "Metalmorph" Trap is on your field or in your GY, a Normal Trap Set by this effect can be activated the turn it was Set.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local CARD_INCOMING_MACHINE = 94661166
local CARD_DRAGON_NAILS = 76076738
-- Mentions : "Incoming Machine!","Dragon Nails"
s.listed_names={CARD_INCOMING_MACHINE,CARD_DRAGON_NAILS,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return (c:IsCode(CARD_INCOMING_MACHINE) or c:IsCode(CARD_DRAGON_NAILS))
	and c:IsAbleToHand()
end
function s.e1con(e,tp,eg)
	return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)

	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		
		local sg=g:Select(tp,1,1,nil)

		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.e2tgt(e,c,tp,r)
	local tp=e:GetHandlerPlayer()

	return c:IsEquipTrap()
	and c:IsLocation(LOCATION_SZONE)
	and c:IsFaceup()
	and c:IsControler(tp)
	and not c:IsImmuneToEffect(e) and r&REASON_EFFECT>0
end
function s.e2btgt(e,c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e2bval(e,re,r)
	return r&REASON_BATTLE==REASON_BATTLE
end
function s.e3con(e,tp,eg)
	local tc=eg:GetFirst()

	return tc:IsFaceup()
	and tc:IsControler(tp)
	and (tc:IsSetCard(SET_RED_EYES) or (tc:IsRace(RACE_MACHINE) and tc:IsLevelAbove(5)))
	and tc:IsMonster()
	and tc:IsLocation(LOCATION_MZONE)
end
function s.e3fil1(c)
	return c:IsNormalSpellTrap()
	and c:IsSSetable()
end
function s.e3fil2(c)
	return c:IsSetCard(SET_METALMORPH)
	and c:IsTrap()
	and (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)))
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(1-tp)
		and s.e3fil1(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil1,tp,0,LOCATION_GRAVE,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	
	local g=Duel.SelectTarget(tp,s.e3fil1,tp,0,LOCATION_GRAVE,1,1,nil)
	
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) and tc:IsSSetable() and Duel.SSet(tp,tc)>0 then
		local e3b1=Effect.CreateEffect(c)
		e3b1:SetDescription(aux.Stringid(id,3))
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e3b1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e3b1:SetCondition(function() return Duel.IsExistingMatchingCard(s.e3fil2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end)
		e3b1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3b1)
	end
end
