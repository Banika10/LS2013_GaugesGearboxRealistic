-------------------------------------------------------------+
-- Copyright © 2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- realistic model
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_Model_realistic';
local _ = newclass(name, Model);
_G[name] = _;

function _:init()
end;

function _:load()
	self.specializations = {}

	-- add specializations
	for _, v in pairs(VehicleTypeUtil.vehicleTypes) do  
		if v ~= nil then
			for i = 1, table.maxn(v.specializations) do
				local vs = v.specializations[i];
				if vs ~= nil and vs == SpecializationUtil.getSpecialization("steerable") then
					--[[ Dodanie nowych specjalizacji --]]
					if not SpecializationUtil.hasSpecialization(trailerPhysics, v.specializations) then -- Fizyka przyczepy
						self.specializations.trailerPhysics = SpecializationUtil.getSpecialization("trailerPhysics");
						table.insert(v.specializations, self.specializations.trailerPhysics);
					end;
					if not SpecializationUtil.hasSpecialization(drivewayPhysic, v.specializations) then -- Fizyka własności jezdnych
						self.specializations.drivewayPhysic = SpecializationUtil.getSpecialization("drivewayPhysic");
						table.insert(v.specializations, self.specializations.drivewayPhysic);
					end;					
					
					--[[ Przekazanie referencji obiektów do Steerable.realisticPhysics --]]
					vs.realisticPhysics = {}
				end;
			end;
		end;
	end;
end;