-------------------------------------------------------------+
-- Copyright © 2012 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- RPM Controller
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_Controller_rpm';
local _ = newclass(name, Controller);
_G[name] = _;

function _:init()
	self.super:init();
end;

function _:load()
	-- Model
	self.model = self:setModel('rpm');
	-- View
	self.view = self:setView();
	self.model:loadSpec(self.view);
end;