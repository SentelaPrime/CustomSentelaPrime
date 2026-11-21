
--Machina Megaframe
local s,id=GetID()
function s.initial_effect(c)
    --Discard itself and another Machine monster: Add 2 Machine Union monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

	--If Special Summoned by a card effect: Send 1 opponent's card to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

--Discard cost filter
function s.costfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsDiscardable()
end

--Discard this card and another Machine monster
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
			and Duel.IsExistingMatchingCard(s.costfilter,tp,
				LOCATION_HAND,0,1,c)
	end
	if chk==2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,
		LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

--Machine Union monster filter
function s.unionfilter(c)
	return c:IsRace(RACE_MACHINE)
		and c:IsType(TYPE_UNION)
		and c:IsAbleToHand()
end

--Check that selected Union monsters have the same Attribute
function s.rescon(sg,e,tp,mg)
	if #sg<2 then return true end
	local att=sg:GetFirst():GetAttribute()
	return sg:FilterCount(function(c)
		return not c:IsAttribute(att)
	end,nil)==0
end

--Check if at least 2 Machine Union monsters with the same Attribute exist
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.unionfilter,tp,
			LOCATION_DECK,0,nil)

		for tc in aux.Next(g) do
			if g:FilterCount(function(c)
				return c:IsAttribute(tc:GetAttribute())
			end,nil)>=2 then
				return true
			end
		end
		return false
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

--Select 2 Machine Union monsters with the same Attribute
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.unionfilter,tp,
		LOCATION_DECK,0,nil)
	if #g<2 then return end

	--Interactive selection: select, unselect and change cards
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,
		s.rescon,1,tp,HINTMSG_ATOHAND,nil,nil,true)

	if not sg or #sg~=2 then return end

	--Add both monsters to hand
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)

		--You cannot Special Summon monsters except Machine monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Special Summon restriction
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end

--Check if Special Summoned by a card effect
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and re~=nil
end

--Send 1 opponent's card to the GY
function s.tgfilter(c)
	return c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,
			0,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,
		0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
