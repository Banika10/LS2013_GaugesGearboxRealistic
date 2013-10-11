-------------------------------------------------------------+
-- Copyright © 2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- manualIgnition model
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_Model_manualIgnition';
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
					if not SpecializationUtil.hasSpecialization(manualIgnition, v.specializations) then
						self.specializations.manualIgnition = SpecializationUtil.getSpecialization("manualIgnition")
						table.insert(v.specializations, self.specializations.manualIgnition);
					end
					
					vs.MANUAL_IGNITION_ERROR = 'Start engine!';
					vs.MANUAL_IGNITION_ERROR2 = 'Wait for the pre heater to finish!';
					
					vs.preHeatOverlay = Overlay:new("preHeatOverlay", Utils.getFilename('preHeatHud.dds', __DIR_GAME_MOD__..self.ModelPrefix..'/images/'), 0.40, 0.1, 0.085, 0.085);
					
					vs.manualIgnition = {}
					vs.manualIgnition.input = Mods:getRegistry(self.ModelPrefix, 'input');
				end;
			end;
		end;
	end;
end;