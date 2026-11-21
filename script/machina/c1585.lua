---Machina Automatron

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Invocar desde la mano y mazo
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spmcon)
	e2:SetTarget(s.spmtg)
	e2:SetOperation(s.spmop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MACHINA}
function s.spfilter(c)
	return c:HasLevel() and c:IsMonster() and c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	return g:CheckWithSumGreater(Card.GetLevel,10)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	local g=rg:SelectWithSumGreater(tp,Card.GetLevel,10)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end

--Condicion
function s.cfilter(c,tp,sc)
	return c~=sc
		and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsRace(RACE_MACHINE)
end

--Machina or Commander Covington, Level 4 or lower
function s.spmfilter(c,e,tp)
	return (c:IsSetCard(SET_MACHINA) or c:IsCode(22666164))
		and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Trigger condition
function s.spmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.spmfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.spmfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
end

--Target
function s.spmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end

--Effect resolution
function s.spmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--Select 1 monster from hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.spmfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g1==0 then return end

	--Select 1 monster from Deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,s.spmfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g2==0 then return end

	--Combine both groups
	g1:Merge(g2)

	--Special Summon both monsters
	local ct=Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	Duel.ShuffleDeck(tp)

	--If both monsters were successfully summoned
	if ct==2 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=g1:GetSum(Card.GetBaseAttack)

		if atk>0 then
			--Gain ATK until the end of the next turn
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
		end
	end
end