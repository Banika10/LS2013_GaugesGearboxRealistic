-------------------------------------------------------------+
-- Copyright © 2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- Realistic Controller
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_Controller_realistic';
local _ = newclass(name, Controller);
_G[name] = _;

function _:init()
	self.super:init();
end;

function _:load()
	self.config = Mods:getRegistry(self.ControllerPrefix, 'config');
	-- Model
	self:setModel('realistic');	
end;