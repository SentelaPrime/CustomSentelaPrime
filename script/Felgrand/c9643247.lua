
--Combate Felgrand
local s,id=GetID()

function s.initial_effect(c)
    --Activate: Special Summon 1 Felgrand Warrior from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

   --Special Summon 1 Felgrand Dragon when a Felgrand monster is destroyed
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCountLimit(1,id+2)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
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
-- EFFECT 1: SPECIAL SUMMON A WARRIOR
--------------------------------------------------

function s.warfilter(c,e,tp)
    return s.isfelgrand(c)
        and c:IsRace(RACE_WARRIOR)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end


function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end


function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local g=Duel.GetMatchingGroup(
        s.warfilter,tp,LOCATION_DECK,0,nil,e,tp)

    if #g==0 then return end

    --Ask the player whether they want to Special Summon
    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        return
    end

    --Select the Felgrand Warrior
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)

    if #sg>0 then
        if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.ShuffleDeck(tp)
        end
    end
end



--------------------------------------------------
-- EFFECT 2: SPECIAL SUMMON A FELGRAND DRAGON
-- WHEN A FELGRAND MONSTER IS DESTROYED
--------------------------------------------------

function s.dragonfilter(c,e,tp)
    return s.isfelgrand(c)
        and c:IsRace(RACE_DRAGON)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.desfilter(c)
    return c:IsReason(REASON_DESTROY)
        and c:IsPreviousLocation(LOCATION_ONFIELD)
        and s.isfelgrand(c)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.desfilter,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.dragonfilter,tp,
                LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,
                1,nil,e,tp)
    end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local g=Duel.GetMatchingGroup(
        s.dragonfilter,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)

    if #g==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)

    if #sg>0 then
        if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.ShuffleDeck(tp)
        end
    end
end
