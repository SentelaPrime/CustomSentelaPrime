
--Mágica Continua Felgrand
local s,id=GetID()

--Unique flag identifier for the LIGHT monster ATK boost
local FLAG_FELGRAND_ATK=9643249

function s.initial_effect(c)
    --Activate Continuous Spell
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --Effect 1: Special Summon a Level 4 or lower LIGHT Warrior
    --when a Level 8 or higher Felgrand monster is Special Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Effect 2: LIGHT monsters gain ATK when a Level 7 or higher
    --Dragon is Special Summoned from the Graveyard
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(s.atkcon)
    e3:SetTarget(s.atktg)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    --Effect 3: Special Summon 1 Dragon Lord Token
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetTarget(s.tktg)
    e4:SetOperation(s.tkop)
    c:RegisterEffect(e4)

    --Effect 4: Send a Level 7 or 8 Dragon to the GY;
    --return this card from the GY to the hand
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCost(s.thcost)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
end

s.listed_card={
    3954901,60681103,6075801,33460840,65187687,1639384,
    69868556
}
s.listed_series={0x12FD}

--------------------------------------------------
-- FELGRAND IDENTIFICATION
--------------------------------------------------

function s.isfelgrand(c)
    return c:IsSetCard(0x12FD)
        or c:IsCode(3954901,60681103,6075801,33460840,65187687,1639384)
end

--------------------------------------------------
-- EFFECT 1: SPECIAL SUMMON A LIGHT WARRIOR
--------------------------------------------------

function s.felgrandfilter(c)
    return s.isfelgrand(c)
        and c:GetLevel()>=8
end

function s.warfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:GetLevel()>0
        and c:GetLevel()<=4
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.felgrandfilter,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.warfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(
        tp,s.warfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)

    if #g>0 then
        if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.ShuffleDeck(tp)
        end
    end
end

--------------------------------------------------
-- EFFECT 2: LIGHT MONSTERS GAIN ATK
--------------------------------------------------

function s.dragonfilter(c)
    return c:IsRace(RACE_DRAGON)
        and c:GetLevel()>=7
        and c:IsPreviousLocation(LOCATION_GRAVE)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if eg:IsExists(s.dragonfilter,1,nil) then
        Duel.RegisterFlagEffect(
            tp,FLAG_FELGRAND_ATK,RESET_PHASE+PHASE_END,0,1)
    end
end

function s.atkcon(e,c)
    local tp=e:GetHandler():GetControler()
    return Duel.GetFlagEffect(tp,FLAG_FELGRAND_ATK)>0
end

function s.atktg(e,c)
    return c:IsFaceup()
        and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.atkval(e,c)
    return c:GetLevel()*100
end

--------------------------------------------------
-- EFFECT 3: SPECIAL SUMMON A DRAGON LORD TOKEN
--------------------------------------------------

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local token=Duel.CreateToken(tp,69868556)

    if token then
        Duel.SpecialSummon(
            token,0,tp,tp,false,false,POS_FACEUP)
    end
end

--------------------------------------------------
-- EFFECT 4: RETURN THIS CARD FROM GY TO HAND
--------------------------------------------------

function s.costfilter(c)
    return c:IsRace(RACE_DRAGON)
        and (c:IsLevel(7) or c:IsLevel(8))
        and (c:IsLocation(LOCATION_HAND)
            or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
        and c:IsAbleToGraveAsCost()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,
            LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,
        LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)

    Duel.SendtoGrave(g,REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()

    if chk==0 then
        return c:IsAbleToHand()
    end

    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,Group.FromCards(c))
    end
end
