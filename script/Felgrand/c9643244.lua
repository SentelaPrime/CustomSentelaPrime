--Guardian del Alma Felgrand

local s,id=GetID()
function s.initial_effect(c)
    --Buscar
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
    --Once per turn: Equip 1 Dragon monster from hand, Deck or GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)

    --Release this card and 1 or more other monsters:
    --Special Summon a Level 7 or 8 Dragon from GY
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCost(s.rscost)
    e5:SetTarget(s.rstg)
    e5:SetOperation(s.rsop)
    c:RegisterEffect(e5)

end
s.listed_card={3954901,60681103,6075801,33460840,65187687,1639384}
s.listed_series={0x12fd}

function s.isfelgrand(c)
    return c:IsSetCard(0x12FD)
        or c:IsCode(3954901,60681103,6075801,33460840,65187687,1639384)
end

--Filtro
function s.thfilter(c)
    return (c:IsCode(s.listed_card) or c:IsSetCard(0x12fd)) and c:IsAbleToHand()
end
--Añadir
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------
-- Effect 2: Equip a Dragon monster
--------------------------------------------------

function s.eqfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsRace(RACE_DRAGON)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsFaceup()
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,
                LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
                0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

    local g=Duel.GetMatchingGroup(s.eqfilter,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)

    if #g==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local tc=g:Select(tp,1,1,nil):GetFirst()

    if not tc then return end

    local fromdeck=tc:IsLocation(LOCATION_DECK)

    if Duel.Equip(tp,tc,c) then

        --Equip limit
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        e1:SetLabelObject(c)
        e1:SetValue(s.eqlimit)
        tc:RegisterEffect(e1)

        --Gain ATK equal to the equipped Dragon's ATK
        local e2=Effect.CreateEffect(tc)
        e2:SetType(EFFECT_TYPE_EQUIP)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(s.eqval)
        tc:RegisterEffect(e2)

        --Gain DEF equal to the equipped Dragon's ATK
        local e3=Effect.CreateEffect(tc)
        e3:SetType(EFFECT_TYPE_EQUIP)
        e3:SetCode(EFFECT_UPDATE_DEFENSE)
        e3:SetValue(s.eqval)
        tc:RegisterEffect(e3)

        if fromdeck then
            Duel.ShuffleDeck(tp)
        end
    end
end

function s.eqlimit(e,c)
    return c==e:GetLabelObject()
end

function s.eqval(e,c)
    local ec=e:GetHandler()
    if ec then
        return math.max(0,ec:GetAttack())
    end
    return 0
end

--------------------------------------------------
-- Effect 3: Release this card and other monsters
--------------------------------------------------

function s.relfilter(c)
    return c:IsMonster()
        and c:IsReleasable()
end

function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()

    if chk==0 then
        return c:IsReleasable()
            and Duel.IsExistingMatchingCard(s.relfilter,tp,
                LOCATION_MZONE,0,1,c)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)

    local ct=Duel.GetMatchingGroupCount(s.relfilter,tp,
        LOCATION_MZONE,0,c)

    local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,
        LOCATION_MZONE,0,1,ct,c)

    --Include this card in the release
    g:AddCard(c)

    --Count the Felgrand monsters released
    local felcount=g:FilterCount(s.isfelgrand,nil)

    e:SetLabel(felcount)

    Duel.Release(g,REASON_COST)
end

--------------------------------------------------
-- Select a Level 7 or 8 Dragon in the GY
--------------------------------------------------

function s.rsfilter(c,e,tp)
    return c:IsRace(RACE_DRAGON)
        and (c:IsLevel(7) or c:IsLevel(8))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.rsfilter,tp,
                LOCATION_GRAVE,0,1,nil,e,tp)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.rsfilter,tp,
        LOCATION_GRAVE,0,1,1,nil,e,tp)

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end

--------------------------------------------------
-- Apply effects according to Felgrand monsters released
--------------------------------------------------

function s.rsop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    local felcount=e:GetLabel()

    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then
        return
    end

    --------------------------------------------------
    -- 1+ Felgrand released:
    -- Gain 500 ATK/DEF for each Level
    --------------------------------------------------

	if felcount>=1 then
		local bonus=tc:GetLevel()*500

		--ATK increase: str3
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(bonus)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)

		--DEF increase: same effect description
		local e2=Effect.CreateEffect(tc)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(bonus)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end

    --------------------------------------------------
    -- 2+ Felgrand released:
    -- Once per turn (Quick Effect): Banish 1 opponent's card
    --------------------------------------------------

	if felcount>=2 then
		--Banish 1 card: str4
		local e3=Effect.CreateEffect(tc)
		e3:SetDescription(aux.Stringid(id,3))
		e3:SetCategory(CATEGORY_REMOVE)
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetTarget(s.banishtg)
		e3:SetOperation(s.banishop)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end

    --------------------------------------------------
    -- 3+ Felgrand released:
    -- Twice per turn (Quick Effect): Negate a targeting effect
    --------------------------------------------------

	if felcount>=3 then
		--Negate effects that target your monsters: str5
		local e4=Effect.CreateEffect(tc)
		e4:SetDescription(aux.Stringid(id,4))
		e4:SetCategory(CATEGORY_NEGATE)
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetCode(EVENT_CHAINING)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCondition(s.negcon)
		e4:SetOperation(s.negop)
		e4:SetCountLimit(2)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e4)
		tc:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	end
end

--------------------------------------------------
-- Quick Effect: Banish 1 opponent's card
--------------------------------------------------

function s.banishfilter(c)
    return c:IsAbleToRemove()
end

function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(1-tp)
            and chkc:IsLocation(LOCATION_ONFIELD)
            and s.banishfilter(chkc)
    end

    if chk==0 then
        return Duel.IsExistingTarget(s.banishfilter,tp,
            0,LOCATION_ONFIELD,1,nil)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    Duel.SelectTarget(tp,s.banishfilter,tp,
        0,LOCATION_ONFIELD,1,1,nil)

    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.banishop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()

    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end

--------------------------------------------------
-- Quick Effect: Negate an effect that targets your monsters
--------------------------------------------------

function s.negfilter(c,tp)
    return c:IsControler(tp)
        and c:IsLocation(LOCATION_MZONE)
        and c:IsType(TYPE_MONSTER)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if not re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end

    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)

    return g~=nil
        and g:IsExists(s.negfilter,1,nil,tp)
        and Duel.IsChainNegatable(ev)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end