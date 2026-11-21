
--Machina Easer
--scripted by SentelaPrimas

local s,id=GetID()

function s.initial_effect(c)
    --You can only Special Summon this card once per turn
    c:SetSPSummonOnce(id)

    --Special Summon itself from hand or GY when Machine monster(s) are Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    --When Summoned: Send a Machina or Commander Covington from Deck to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.copytg)
    e2:SetOperation(s.copyop)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c=e2:Clone()
    e2c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2c)

    --If this card is sent to the GY: Target 1 EARTH monster with 1000 or less ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

s.listed_series={SET_MACHINA}
s.listed_names={22666164}

--------------------------------------------------
-- Special Summon itself
--------------------------------------------------

function s.spfilter(c,tp)
    return c:IsFaceup()
        and c:IsControler(tp)
        and c:IsRace(RACE_MACHINE)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--------------------------------------------------
-- Send a Machina or Commander Covington from Deck
--------------------------------------------------

function s.copyfilter(c)
    return c:IsMonster()
        and (c:IsSetCard(SET_MACHINA) or c:IsCode(22666164))
        and c:IsAbleToGrave()
end

function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.copyfilter,tp,
            LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.copyfilter,tp,
        LOCATION_DECK,0,1,1,nil)

    local tc=g:GetFirst()
    if not tc then return end

    local atk=tc:GetBaseAttack()
    local code=tc:GetOriginalCode()

    if Duel.SendtoGrave(tc,REASON_EFFECT)>0
        and tc:IsLocation(LOCATION_GRAVE) then

        --Gain ATK equal to the sent monster's original ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        c:RegisterEffect(e1)

        --Change this card's name to the sent monster's name
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_CODE)
        e2:SetValue(code)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        c:RegisterEffect(e2)

        --Copy the sent monster's effects
        Duel.MajesticCopy(c,tc)
    end
end

--------------------------------------------------
-- If sent to the GY: Target 1 EARTH monster
--------------------------------------------------

function s.gyfilter(c)
    return c:IsFaceup()
        and c:IsAttribute(ATTRIBUTE_EARTH)
        and c:IsAttackBelow(1001)
end

--Count Machina cards you control
function s.machinafilter(c)
    return c:IsSetCard(SET_MACHINA)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE)
            and chkc:IsControler(tp)
            and s.gyfilter(chkc)
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.gyfilter,tp,
            LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

    --800 ATK for each Machina card you control
    local ct=Duel.GetMatchingGroupCount(s.machinafilter,tp,
        LOCATION_ONFIELD,0,nil)

    local atk=800*ct

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e1)

    --The targeted monster cannot attack directly
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e2)
end
