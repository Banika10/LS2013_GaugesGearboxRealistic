-------------------------------------------------------------+
-- Copyright © 2012-2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- Gearbox Controller
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_Controller_gearbox';
local _ = newclass(name, Controller);
_G[name] = _;

function _:init()
	self.super:init();
end;

function _:load()
	self.config = Mods:getRegistry(self.ControllerPrefix, 'config');	
	-- Model
	self.modelGearbox = self:setModel('gearbox');
	Mods:setRegistry(self.ControllerPrefix, 'Model_gearbox', self.modelGearbox);
	--self:setModel('manualIgnition');
	-- View
	self.view = self:setView();	
	self.modelGearbox:loadSpec(self.view);
end;