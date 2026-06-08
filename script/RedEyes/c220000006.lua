-- Jinzo, Black Fullmetal Dragon Armored
local s,id,o=GetID()
-- c220000006
function s.initial_effect(c)
	-- "Jinzo" + 1 "Red-Eyes" monster (Dragon or Machine)
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- Must first be Fusion Summoned.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.e0lim)
	c:RegisterEffect(e0)
	--[[
	"Red-Eyes" and Level 5 or higher Machine monsters you control are unaffected by your opponent's Trap effects.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(s.e1fil))
	e1:SetValue(s.e1val)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	If this card is Special Summoned:
	You can target up to 3 Traps in your GY with an effect that equip themselves to a monster;
	shuffle them into the Deck,
	then if "Max Metalmorph" was shuffled into your Deck by this effect,
	you can shuffle an equal number of Set cards your opponent controls into the Deck.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[H1PT]
	At the start of your Battle Phase:
	You can take control of the 1 monster your opponent controls with the highest ATK (your choice, if tied),
	until the end of the Battle Phase, also it must attack this turn, if able.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local RESETS_END_PHASE = RESET_PHASE+PHASE_END
-- Mentions : "Jinzo","Max Metalmorph"
s.listed_names={CARD_JINZO,CARD_MAX_METALMORPH,id}
-- Archetype : Jinzo
s.listed_series={SET_JINZO}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsCode(CARD_JINZO)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsSetCard(SET_RED_EYES)
	and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_MACHINE))
end
function s.e0lim(e,se,sp,st)
	local c=e:GetHandler()

	return not c:IsLocation(LOCATION_EXTRA)
	or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.e1fil(c)
	return (c:IsSetCard(SET_RED_EYES)
	or (c:IsLevelAbove(5) and c:IsRace(RACE_MACHINE)))
	and c:IsMonster()
end
function s.e1val(e,te)
	local tc=te:GetOwner()

	return te:IsTrapEffect()
	and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
end
function s.e2fil1(c)
	return c:IsEquipTrap()
	and c:IsAbleToDeck()
end
function s.e2fil2(c)
	return c:IsFacedown()
	and c:IsAbleToDeck()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e2fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil1,tp,LOCATION_GRAVE,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

	local max=Duel.GetMatchingGroupCount(s.e2fil1,tp,LOCATION_GRAVE,0,nil)
	if max>3 then
		max=3
	end

	local g=Duel.SelectTarget(tp,s.e2fil1,tp,LOCATION_GRAVE,0,1,max,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local g1=Duel.GetTargetCards(e)
	if g1:GetCount()>0 then
		local ct=Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

		local cond1=0
		for tc in g1:Iter() do
			if (tc:GetCode() == CARD_MAX_METALMORPH) and tc:IsLocation(LOCATION_DECK) then
				cond1=1
				break
			end
		end

		local cond2=(Duel.GetMatchingGroupCount(s.e2fil2,tp,0,LOCATION_ONFIELD,nil)>=ct)
		if cond1==1 and cond2 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
			Duel.BreakEffect()

			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g2=Duel.SelectMatchingCard(tp,s.e2fil2,tp,0,LOCATION_ONFIELD,ct,ct,nil)

			if g2:GetCount()>0 then
				Duel.HintSelection(g2)
				Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)

	if chk==0 then
		return g
		and g:IsExists(Card.IsControlerCanBeChanged,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	if not g or g:GetCount()==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	
	g:Match(Card.IsControlerCanBeChanged,nil)
	if g:GetCount()>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		g=g:Select(tp,1,1,nil)
	end
	
	if g:GetCount()>0 then
		Duel.HintSelection(g)

		local tc=g:GetFirst()
		Duel.GetControl(tc,tp,PHASE_BATTLE,1)

		local e3b1=Effect.CreateEffect(c)
		e3b1:SetType(EFFECT_TYPE_SINGLE)
		e3b1:SetCode(EFFECT_MUST_ATTACK)
		e3b1:SetReset(RESETS_END_PHASE)
		tc:RegisterEffect(e3b1)
	end
end
