--
-- adds manualIgnition to all Vehicles that have the "steerable" specialization.
--
--
-- author:    	Xentro (www.ls-uk.info)(Marcus@Xentro.se)
-- @version:    v1.0
-- @date:       2012-10-26
-- @history:    v1.0 - inital implementation
-- 
--
SpecializationUtil.registerSpecialization("manualIgnition", "manualIgnition", g_currentModDirectory .. "app/externalScripts/manualIgnition.lua")

function add_manualIgnition()
	for _, v in pairs(VehicleTypeUtil.vehicleTypes) do  
		if v ~= nil then
			for i = 1, table.maxn(v.specializations) do
				local vs = v.specializations[i];
				if vs ~= nil and vs == SpecializationUtil.getSpecialization("steerable") then
					if not SpecializationUtil.hasSpecialization(manualIgnition, v.specializations) then
						table.insert(v.specializations, SpecializationUtil.getSpecialization("manualIgnition"));
					end
					vs.MANUAL_IGNITION_START = g_i18n:getText("MANUAL_IGNITION_START");
					vs.MANUAL_IGNITION_PRE = g_i18n:getText("MANUAL_IGNITION_PRE");
					vs.MANUAL_IGNITION_ERROR = g_i18n:getText("MANUAL_IGNITION_ERROR");
					vs.MANUAL_IGNITION_ERROR2 = g_i18n:getText("MANUAL_IGNITION_ERROR2");
					
					vs.preHeatOverlay = Overlay:new("preHeatOverlay", Utils.getFilename("images/preHeatHud.dds", g_currentModDirectory), 0.40, 0.1, 0.085, 0.085);
				end;
			end;
		end;
	end;
end;
add_manualIgnition();