--Vacio de la Oscuridad

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion & Alt Procedure
	Fusion.AddProcMixRep(c,true,true,s.matfilters,1,99,512000214)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)


end

s.listed_names={512000214}


function s.matfilters(c,fc,sumtype,sump)
	return c:IsLevelAbove(7) or c:IsRankAbove(7) or c:IsType(TYPE_LINK)
end

function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.matfilter(c,tp)
	return c:IsAbleToGraveAsCost() and (c:IsFaceup() or c:IsControler(tp))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
end