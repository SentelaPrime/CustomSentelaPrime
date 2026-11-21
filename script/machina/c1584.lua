
--Machina Trailblazer
local s,id=GetID()
function s.initial_effect(c)
	--Union Procedure
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),false)
	--Quick Effect: Special Summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--On Summon: Equip 1 EARTH Machine Union monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MACHINA}

--Quick Effect: Target a Machina card you control
function s.spfilter(c)
	return c:IsSetCard(SET_MACHINA) and c:IsFaceup()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE)
			and s.spfilter(chkc) and chkc~=e:GetHandler()
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup()
		or not tc:IsControler(tp) then return end
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end


--EARTH Machine Union filter
function s.eqfilter(c,ec)
	return c:IsRace(RACE_MACHINE)
		and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsType(TYPE_UNION)
		and c:CheckUnionTarget(ec)
		and aux.CheckUnionEquip(c,ec)
end

--Check if there is a valid Machine monster and Union monster
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then
		return ft>0
			and Duel.IsExistingMatchingCard(function(c)
				return c:IsFaceup() and c:IsRace(RACE_MACHINE)
					and Duel.IsExistingMatchingCard(s.eqfilter,tp,
						LOCATION_HAND|LOCATION_DECK,0,1,nil,c)
			end,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end

--Equip Union monster when effect resolves
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	--Select a valid Union monster from hand or Deck
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsRace(RACE_MACHINE)
			and c:IsAttribute(ATTRIBUTE_EARTH)
			and c:IsType(TYPE_UNION)
			and c:IsAbleToChangeControler()
	end,tp,LOCATION_HAND|LOCATION_DECK,0,nil)

	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=g:Filter(function(c)
		return Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsRace(RACE_MACHINE)
				and c:CheckUnionTarget(tc)
				and aux.CheckUnionEquip(c,tc)
		end,tp,LOCATION_MZONE,0,1,nil)
	end,nil):Select(tp,1,1,nil):GetFirst()

	if not ec then return end

	--Select Machine monster only during resolution
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local mg=Duel.GetMatchingGroup(function(tc)
		return tc:IsFaceup() and tc:IsRace(RACE_MACHINE)
			and ec:CheckUnionTarget(tc)
			and aux.CheckUnionEquip(ec,tc)
	end,tp,LOCATION_MZONE,0,nil)

	if #mg==0 then return end
	local tc=mg:Select(tp,1,1,nil):GetFirst()

if tc and Duel.Equip(tp,ec,tc) then
    aux.SetUnionState(ec)

    if ec:IsLocation(LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    end
end
end
