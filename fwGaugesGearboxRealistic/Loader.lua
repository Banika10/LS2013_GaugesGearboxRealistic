-------------------------------------------------------------+
-- Copyright © 2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- Loader
------------------------------------------------------------*/

-- [[ Inicjowanie modyfikacji we Frameworku by Miko --]]
if Utils ~= nil and Utils.frameworkByMiko ~= nil then 
	local modName = 'fwGaugesGearboxRealistic';
	if Utils.frameworkByMiko.modsModule:get(modName) == nil then
		table.insert(Utils.frameworkByMiko.modsCapture, {name = modName, enable = true});
		print('Mod '..modName..' send to capture');
	end;
end;
