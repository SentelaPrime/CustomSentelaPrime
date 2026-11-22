
--Guerrero del Alma Felgrand
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

    --3. Fusion Summon a "Felgrand" Fusion Monster
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+2)
    e5:SetTarget(s.fustg)
    e5:SetOperation(s.fusop)
    c:RegisterEffect(e5)

    --4. Release this card and other monsters to revive a Dragon
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3))
    e6:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1,id+3)
    e6:SetCost(s.rscost)
    e6:SetTarget(s.rstg)
    e6:SetOperation(s.rsop)
    c:RegisterEffect(e6)

    --Immunity while equipped with a Dragon
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetCode(EFFECT_IMMUNE_EFFECT)
    e7:SetValue(s.immval)
    c:RegisterEffect(e7)
end

s.listed_card={3954901,60681103,6075801,33460840,65187687,1639384}
s.listed_series={0x12FD}

--------------------------------------------------
-- FELGRAND IDENTIFICATION
--------------------------------------------------

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

--Unaffected by opponent's card effects while equipped with a Dragon
function s.immval(e,re)
    local c=e:GetHandler()
    local g=c:GetEquipGroup()
    return re:GetOwnerPlayer()~=c:GetControler()
        and g:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end

--------------------------------------------------
-- EFFECT 3: FUSION SUMMON
--------------------------------------------------

--Materials: Dragon monsters with exactly 2800 ATK and DEF
function s.matfilter(c)
    return c:IsFaceup()
        and c:IsRace(RACE_DRAGON)
        and c:GetAttack()==2800
        and c:GetDefense()==2800
        and c:IsAbleToGrave()
        and c:IsCanBeFusionMaterial()
end

--Require exactly 3 materials
function s.fcheck(tp,sg,fc)
    return #sg==3 and sg:FilterCount(s.matfilter,nil)==3
end

--Check if a Felgrand Fusion Monster can be summoned
function s.fusfilter(c,e,tp,mg,chkf)
    return c:IsType(TYPE_FUSION)
        and s.isfelgrand(c)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false)
        and c:CheckFusionMaterial(mg,nil,chkf)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mg=Duel.GetMatchingGroup(
        s.matfilter,tp,LOCATION_MZONE,0,nil)

    if chk==0 then
        if #mg<3 then return false end

        local old=aux.FCheckAdditional
        aux.FCheckAdditional=s.fcheck

        local res=Duel.IsExistingMatchingCard(
            s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,tp)

        aux.FCheckAdditional=old
        return res
    end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_MZONE)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

    local mg=Duel.GetMatchingGroup(
        s.matfilter,tp,LOCATION_MZONE,0,nil)
    if #mg<3 then return end

    local old=aux.FCheckAdditional
    aux.FCheckAdditional=s.fcheck

    local sg=Duel.GetMatchingGroup(
        s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,tp)

    if #sg==0 then
        aux.FCheckAdditional=old
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=sg:Select(tp,1,1,nil)
    local tc=tg:GetFirst()

    if not tc then
        aux.FCheckAdditional=old
        return
    end

    --Select exactly 3 Fusion Materials
    local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)

    aux.FCheckAdditional=old

    if not mat or #mat~=3 then return end

    --Record materials and send them to the GY
    tc:SetMaterial(mat)
    if Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)~=3 then
        return
    end

    Duel.BreakEffect()

    --Fusion Summon
    if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
        tc:CompleteProcedure()
    end
end

--------------------------------------------------
-- EFFECT 4: RELEASE AND SPECIAL SUMMON
--------------------------------------------------

function s.relfilter(c)
    return c:IsMonster() and c:IsReleasable()
end

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

    g:AddCard(c)

    --Count released Felgrand monsters
    local felcount=g:FilterCount(s.isfelgrand,nil)
    e:SetLabel(felcount)

    Duel.Release(g,REASON_COST)
end

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
    -- 1+ FELGRAND:
    -- Opponent cannot activate cards/effects while this
    -- monster attacks, until the end of the Damage Step
    --------------------------------------------------
    if felcount>=1 then
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(s.aclimit)
        e1:SetCondition(s.atkcon)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e1)

        tc:RegisterFlagEffect(0,
            RESET_EVENT|RESETS_STANDARD,
            EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
    end

    --------------------------------------------------
    -- 2+ FELGRAND:
    -- Once per turn, Special Summon a Dragon from GY
    -- or banishment
    --------------------------------------------------
    if felcount>=2 then
        local e2=Effect.CreateEffect(tc)
        e2:SetDescription(aux.Stringid(id,5))
        e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e2:SetType(EFFECT_TYPE_QUICK_O)
        e2:SetCode(EVENT_FREE_CHAIN)
        e2:SetRange(LOCATION_MZONE)
        e2:SetCountLimit(1)
        e2:SetTarget(s.spdgtg)
        e2:SetOperation(s.spdgop)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e2)

        tc:RegisterFlagEffect(0,
            RESET_EVENT|RESETS_STANDARD,
            EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
    end

    --------------------------------------------------
    -- 3+ FELGRAND:
    -- Gain ATK equal to its Level x 100
    --------------------------------------------------
    if felcount>=3 then
        local e3=Effect.CreateEffect(tc)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_UPDATE_ATTACK)
        e3:SetValue(s.atkval)
        e3:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e3)

        tc:RegisterFlagEffect(0,
            RESET_EVENT|RESETS_STANDARD,
            EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,6))
    end
end

--------------------------------------------------
-- 1+ EFFECT: CANNOT ACTIVATE WHILE ATTACKING
--------------------------------------------------

function s.atkcon(e)
    return Duel.GetAttacker()==e:GetHandler()
end

function s.aclimit(e,re,tp)
    return tp~=e:GetHandlerPlayer()
end

--------------------------------------------------
-- 2+ EFFECT: SPECIAL SUMMON A DRAGON
--------------------------------------------------

function s.spdgfilter(c,e,tp)
    return c:IsRace(RACE_DRAGON)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spdgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.spdgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,
                1,nil,e,tp)
    end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spdgop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spdgfilter,tp,
        LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)

    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

--------------------------------------------------
-- 3+ EFFECT: ATK = LEVEL x 100
--------------------------------------------------

function s.atkval(e,c)
    return e:GetHandler():GetLevel()*100
end
