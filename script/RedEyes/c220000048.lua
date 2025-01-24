-- Dark Flare Swordsman
local s,id,o=GetID()
-- c220000048
function s.initial_effect(c)
	-- "Dark Magician" + 1 "Flame Swordsman" monster
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN,s.m2fil)
	c:EnableReviveLimit()
	-- You take no battle damage from battles involving this card.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Monsters your opponent controls cannot target Warrior monsters for attacks, except "Shadow Flare Knight".
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	--[[
	[SOPT]
	Once per turn, during damage calculation, if this card battles an opponent's monster with 2400 or more ATK (Quick Effect):
	You can make this card gain ATK equal to its current DEF until the end of this Battle Phase.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	If your opponent Special Summons a Level 5 or higher monster(s) (Quick Effect):
	You can Tribute 1 face-up monster;
	destroy that Summoned monster(s),
	and if you do, inflict 500 damage to your opponent.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,0})
	e4:SetCost(s.e4cst)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect and sent to the GY:
	You can banish this card from your GY;
	Special Summon 1 Level 8 or lower FIRE Warrior monster from your hand or Deck,
	and if you do, inflict 500 damage to your opponent.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCost(aux.bfgcost)
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
-- Mentions : "Dark Magician"
s.listed_names={CARD_DARK_MAGICIAN,id}
-- Helpers
function s.m2fil(c,fc,sumtype,tp)
	-- "Flame Swordsman" monsters
	return (c:IsSetCard(0xfe2)
	or c:IsCode(45231177)
	or c:IsCode(73936388)
	or c:IsCode(27704731)
	or c:IsCode(1047075)
	or c:IsCode(50903514)
	or c:IsCode(324483)
	or c:IsCode(98642179))
end
function s.e2val(e,c)
	return not c:IsCode(id)
	and c:IsFaceup()
	and c:IsRace(RACE_WARRIOR)
end
function s.e3con(e,tp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:GetAttack()>=2400
end
function s.e3fil(c)
	return c:IsLevel(4) and c:IsAbleToGrave()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e3b=Effect.CreateEffect(c)
		e3b:SetType(EFFECT_TYPE_SINGLE)
		e3b:SetCode(EFFECT_UPDATE_ATTACK)
		e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3b:SetValue(c:GetDefense())
		e3b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e3b)
	end
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,Card.IsFaceup,1,false,nil,nil)
	end
	
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsFaceup,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.e4fil(c,e,tp)
	return c:IsSummonPlayer(1-tp)
	and c:IsLevelAbove(5)
	and (not e or c:IsRelateToEffect(e))
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.e4fil,nil,nil,tp)

	if chk==0 then
		return g:GetCount()>0
		and not eg:IsContains(c)
	end
	
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.e4evt(e,tp)
	local g=eg:Filter(s.e4fil,nil,e,tp)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.e5con(e)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.e5fil(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE)
	and c:IsRace(RACE_WARRIOR)
	and c:IsLevelBelow(8)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e5fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.e5evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	local g=Duel.SelectMatchingCard(tp,s.e5fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
