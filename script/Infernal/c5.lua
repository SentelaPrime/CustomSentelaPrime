--Infernal-Eyes Fusion

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial,0x898),nil,s.fextra,nil,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
end
function s.fextra(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0x898)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.fcheck(tp,sg,fc,sumtype,tp)
	return sg:IsExists(s.ffilter,1,nil,fc,sumtype,tp)
end
function s.ffilter(c,fc,sumtype,tp)
	local mat=fc.material
	local set=fc.material_setcode
	local res
	if mat then
		for _,code in ipairs(mat) do
			res=res or (c:IsSummonCode(nil,SUMMON_TYPE_FUSION,PLAYER_NONE,code) and c:IsSetCard(0x898,fc,sumtype,tp))
		end
	elseif set then
		res=res or (c:IsSetCard(0x898,fc,sumtype,tp) and fc:ListsArchetypeAsMaterial(0x898))
	else
		return false
	end
	return res
end
local function IsInfernalEyesMonster(c)
    return c:IsSetCard(0x898)
end