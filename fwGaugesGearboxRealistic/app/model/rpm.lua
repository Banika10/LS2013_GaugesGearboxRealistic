-------------------------------------------------------------+
-- Copyright © 2012-2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- rpm model
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_Model_rpm';
local _ = newclass(name, Model);
_G[name] = _;

function _:init()
end;

function _:load()
end;

function _:loadSpec(view)
	-- add specializations
	for _, v in pairs(VehicleTypeUtil.vehicleTypes) do  
		if v ~= nil then
			for i = 1, table.maxn(v.specializations) do
				local vs = v.specializations[i];
				if vs ~= nil and vs == SpecializationUtil.getSpecialization("steerable") then
					--[[ Dodanie nowych specjalizacji --]]
					if not SpecializationUtil.hasSpecialization(gaugeRpm, v.specializations) then -- Zmienne obrotomierza
						local spec = SpecializationUtil.getSpecialization("gaugeRpm");
						table.insert(v.specializations, spec);
					end;	

					--[[ Przekazanie referencji widoku do Steerable.Gauges_View_rpm --]]
					vs.Gauges_View_rpm = view;			
				end;
			end;
		end;
	end;
end;