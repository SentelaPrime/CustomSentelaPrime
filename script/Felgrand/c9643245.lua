
--Paladin del Alma Felgrand
local s,id=GetID()

function s.initial_effect(c)
    --1. Add 1 "Felgrand" card from Deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)

    --2. Equip 1 Dragon monster from hand, Deck or GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)

    --3. Release this card and other monsters to Special Summon a Level 7/8 Dragon
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+2)
    e5:SetCost(s.rscost)
    e5:SetTarget(s.rstg)
    e5:SetOperation(s.rsop)
    c:RegisterEffect(e5)
end

s.listed_card={3954901,60681103,6075801,33460840,65187687,1639384}
s.listed_series={0x12FD}

--Identify "Felgrand" cards
function s.isfelgrand(c)
    return c:IsSetCard(0x12FD)
        or c:IsCode(3954901,60681103,6075801,33460840,65187687,1639384)
end

--------------------------------------------------
-- EFFECT 1: SEARCH
--------------------------------------------------

function s.thfilter(c)
    return s.isfelgrand(c) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--------------------------------------------------
-- EFFECT 2: EQUIP A DRAGON
--------------------------------------------------

function s.eqfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsRace(RACE_DRAGON)
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

        if fromdeck then
            Duel.ShuffleDeck(tp)
        end
    end
end

function s.eqlimit(e,c)
    return c==e:GetLabelObject()
end

--------------------------------------------------
-- EFFECT 3: RELEASE THIS CARD AND OTHER MONSTERS
--------------------------------------------------

function s.relfilter(c)
    return c:IsMonster() and c:IsReleasable()
end

--Release this card and 1 or more other monsters
function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsReleasable()
            and Duel.IsExistingMatchingCard(
                s.relfilter,tp,LOCATION_MZONE,0,1,c)
    end

    local ct=Duel.GetMatchingGroupCount(
        s.relfilter,tp,LOCATION_MZONE,0,c)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(
        tp,s.relfilter,tp,LOCATION_MZONE,0,1,ct,c)

    --Include this card in the release
    g:AddCard(c)

    --Count the released "Felgrand" monsters
    local felcount=g:FilterCount(s.isfelgrand,nil)
    e:SetLabel(felcount)

    Duel.Release(g,REASON_COST)
end

--Level 7 or 8 Dragon in the GY
function s.rsfilter(c,e,tp)
    return c:IsRace(RACE_DRAGON)
        and (c:IsLevel(7) or c:IsLevel(8))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.rsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.rsfilter,tp,
        LOCATION_GRAVE,0,1,1,nil,e,tp)

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end

function s.rsop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local felcount=e:GetLabel()

    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then
        return
    end

    --------------------------------------------------
    -- 1+ FELGRAND: Cannot be destroyed or affected
    --------------------------------------------------
    if felcount>=1 then
        --Cannot be destroyed
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e1)

        --Unaffected by card effects
        local e2=Effect.CreateEffect(tc)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_IMMUNE_EFFECT)
        e2:SetValue(s.immval)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e2)

        --Client hint: str3
        tc:RegisterFlagEffect(0,
            RESET_EVENT|RESETS_STANDARD,
            EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
    end

    --------------------------------------------------
    -- 2+ FELGRAND: Attack all opponent's monsters
    --------------------------------------------------
    if felcount>=2 then
        local e3=Effect.CreateEffect(tc)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_ATTACK_ALL)
        e3:SetValue(1)
        e3:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e3)

        --Client hint: str4
        tc:RegisterFlagEffect(0,
            RESET_EVENT|RESETS_STANDARD,
            EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
    end

    --------------------------------------------------
    -- 3+ FELGRAND: Twice per turn, negate opponent's
    -- card effect and banish 1 card from their GY
    --------------------------------------------------
    if felcount>=3 then
        local e4=Effect.CreateEffect(tc)
        e4:SetDescription(aux.Stringid(id,4))
        e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
        e4:SetType(EFFECT_TYPE_QUICK_O)
        e4:SetCode(EVENT_CHAINING)
        e4:SetRange(LOCATION_MZONE)
        e4:SetCountLimit(2)
        e4:SetCondition(s.negcon)
        e4:SetOperation(s.negop)
        e4:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e4)

        --Client hint: str5
        tc:RegisterFlagEffect(0,
            RESET_EVENT|RESETS_STANDARD,
            EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
    end
end

--------------------------------------------------
-- IMMUNITY: ONLY OPPONENT'S CARD EFFECTS
--------------------------------------------------

function s.immval(e,re)
    local c=e:GetHandler()
    return re:GetOwnerPlayer()~=c:GetControler()
end

--------------------------------------------------
-- QUICK EFFECT: NEGATE AND BANISH
--------------------------------------------------

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
        and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
        and Duel.IsChainNegatable(ev)
end

function s.rmfilter(c)
    return c:IsAbleToRemove()
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    --Negate the opponent's activated effect
    if Duel.NegateEffect(ev) then
        --Then banish 1 card from the opponent's GY
        local g=Duel.GetMatchingGroup(
            s.rmfilter,tp,0,LOCATION_GRAVE,nil)

        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=g:Select(tp,1,1,nil)
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        end
    end
end
