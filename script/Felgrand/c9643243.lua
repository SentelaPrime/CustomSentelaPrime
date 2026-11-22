---Caballero del Alma Felgrand

local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Felgrand" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
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
	--Send 1 Dragon from Deck to GY, then Special Summon a Felgrand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
    --Change this card's Level to the highest Level of a Level 7 or 8 Felgrand monster
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_CHANGE_LEVEL)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(s.lvltg)
    e5:SetValue(s.lvlval)
    c:RegisterEffect(e5)

end

s.listed_card={60681103,3954901,6075801,33460840,65187687,1639384}
s.listed_series={0x12FD}


function s.thfilter(c)
	if not c:IsAbleToHand() then return false end
	return (c:IsCode(60681103) or c:IsSetCard(0x12FD))
end
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



function s.isfelgrand(c)
    return c:IsCode(60681103,3954901,6075801,33460840,65187687,1639384)
        or c:IsSetCard(0x12FD)
end


--Any Dragon monster that can be sent to the GY
function s.tgfilter(c)
    return c:IsRace(RACE_DRAGON)
        and c:IsAbleToGrave()
end

function s.spfilter(c,e,tp)
    return c:IsRace(RACE_DRAGON)
        and (c:IsLevel(7) or c:IsLevel(8))
        and s.isfelgrand(c)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,
            LOCATION_DECK,0,1,nil)
    end

    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    --Send 1 Dragon monster from Deck to GY
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,
        LOCATION_DECK,0,1,1,nil)

    if #g==0 then return end

    if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

    --Special Summon is optional
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local sg=Duel.GetMatchingGroup(s.spfilter,tp,
        LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)

    if #sg==0 then return end

    local sc=sg:Select(tp,0,1,nil):GetFirst()
    if sc then
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
    end
end

--------------------------------------------------
-- Change this card's Level
--------------------------------------------------

function s.lvltg(e,c)
    if c~=e:GetHandler() then return false end

    return Duel.IsExistingMatchingCard(function(tc)
        return tc~=c
            and tc:IsFaceup()
            and tc:IsRace(RACE_DRAGON)
            and (tc:IsLevel(7) or tc:IsLevel(8))
            and s.isfelgrand(tc)
    end,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

function s.lvlval(e,c)
    local g=Duel.GetMatchingGroup(function(tc)
        return tc~=c
            and tc:IsFaceup()
            and tc:IsRace(RACE_DRAGON)
            and (tc:IsLevel(7) or tc:IsLevel(8))
            and s.isfelgrand(tc)
    end,c:GetControler(),LOCATION_MZONE,0,nil)

    local lv=0

    for tc in aux.Next(g) do
        if tc:GetLevel()>lv then
            lv=tc:GetLevel()
        end
    end

    return lv
end