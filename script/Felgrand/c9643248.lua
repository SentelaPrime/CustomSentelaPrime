
--Doble Movimiento Felgrand
local s,id=GetID()

function s.initial_effect(c)
    --Add 1 Level 4 LIGHT Warrior from Deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --Banish this card from GY: Special Summon 1 Felgrand Dragon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.gycon)
    e2:SetCost(s.gycost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
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
-- EFFECT 1: ADD LIGHT WARRIOR LEVEL 4
--------------------------------------------------

function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsRace(RACE_WARRIOR)
        and c:IsLevel(4)
        and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end

    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.gyspfilter(c,e,tp)
    return s.isfelgrand(c)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)

    if #g==0 then return end

    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)

    local tc=g:GetFirst()
    if not tc or not tc:IsLocation(LOCATION_HAND) then return end

    --If the added monster is Felgrand, optionally Special Summon it
    if not s.isfelgrand(tc) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    if not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end

    local gy=Duel.GetMatchingGroup(
        s.gyspfilter,tp,LOCATION_GRAVE,0,nil,e,tp)

    if #gy==0 then return end

    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=gy:Select(tp,1,1,nil)

    if #sg==0 then return end

    sg:AddCard(tc)

    Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end

--------------------------------------------------
-- EFFECT 2: BANISH THIS CARD FROM GY
-- SPECIAL SUMMON 1 FELGRAND DRAGON FROM GY
--------------------------------------------------

function s.dragonfilter(c,e,tp)
    return s.isfelgrand(c)
        and c:IsRace(RACE_DRAGON)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(
        function(c)
            return s.isfelgrand(c) and c:IsRace(RACE_DRAGON)
        end,
        tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end

function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()

    if chk==0 then
        return c:IsAbleToRemoveAsCost()
    end

    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.dragonfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(
        tp,s.dragonfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)

    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
