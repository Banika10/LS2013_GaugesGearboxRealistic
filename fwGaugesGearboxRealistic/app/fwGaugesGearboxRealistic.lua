-------------------------------------------------------------+
-- Copyright © 2012-2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- Initialization
------------------------------------------------------------*/

fwGaugesGearboxRealistic_Mod = newclass("fwGaugesGearboxRealistic_Mod");

function fwGaugesGearboxRealistic_Mod:init(modName)
	-- Register Specializations
	SpecializationUtil.registerSpecialization("gaugeRpm", "gaugeRpm", Utils.getFilename('gaugeRpm.lua', __DIR_GAME_MOD__..modName..'/app/specialization/'));	
	SpecializationUtil.registerSpecialization("gearboxSpecialization", "gearboxSpecialization", Utils.getFilename('gearboxSpecialization.lua', __DIR_GAME_MOD__..modName..'/app/specialization/'));	
	SpecializationUtil.registerSpecialization("trailerPhysics", "trailerPhysics", Utils.getFilename('trailerPhysics.lua', __DIR_GAME_MOD__..modName..'/app/specialization/'));	
	SpecializationUtil.registerSpecialization("drivewayPhysic", "drivewayPhysic", Utils.getFilename('drivewayPhysic.lua', __DIR_GAME_MOD__..modName..'/app/specialization/'));
end;

function fwGaugesGearboxRealistic_Mod:load()
	self.rpmController 	 		= MVC_:getInstance(self.modName, 'rpm');
	self.gearboxController 		= MVC_:getInstance(self.modName, 'gearbox');
	self.realisticController 	= MVC_:getInstance(self.modName, 'realistic');		
end;