--El Despertar de Numeronius
--Primas yo pues
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)


    --Desterrarse
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(s.targ)
    e2:SetValue(s.val)
    e2:SetOperation(s.protectop)
    c:RegisterEffect(e2)


end

s.listed_series={SET_NUMBER}
s.listed_names={79747096,89477759}



function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(IsCode,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,79747096)
end


function s.spfilter(c,e,tp)
	return c:IsCode(89477759) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.matfilter(c)
	return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ)
end
function s.rmgchk(f,id)
	return function(c)
		return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and f(c,id)
	end
end




function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.rmgchk(Card.IsCode,79747096),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingTarget(s.rmgchk(s.matfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,4,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local atg1=Duel.SelectTarget(tp,s.rmgchk(Card.IsCode,79747096),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local atg2=Duel.SelectTarget(tp,s.rmgchk(s.matfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,4,4,atg1)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	atg1:Merge(atg2)
	local lvgg=atg1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,tp,LOCATION_EXTRA)
	if #lvgg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,lvgg,#lvgg,0,0)
	end
end



function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(10000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(1000)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
		local tg=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
		if #tg==5 then
			Duel.Overlay(tc,tg)
		end
	end
	local spc=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limittg)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetLabel(spc)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e3:SetValue(s.countval)
	Duel.RegisterEffect(e3,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.limittg(e,c,tp)
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
	return sp-e:GetLabel()>=1
end
function s.countval(e,re,tp)
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
	if sp-e:GetLabel()>=1 then return 0 else return 1-sp+e:GetLabel() end
end

---------------Efecto de proteccion

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_NUMBER) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

function s.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.val(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.protectop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_EFFECT)
end