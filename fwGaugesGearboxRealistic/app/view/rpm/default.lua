-------------------------------------------------------------+
-- Copyright © 2012-2013 Rafa³ Miko³ajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- RPM View
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_View_rpm';
local _ = newclass(name, View);
_G[name] = _;

function _:init()
end;

function _:load()	
	self.controller = self:getController();
	self.rpmGaugeWindowTipMaxWidth = 0.196;
	
	-- RPM Gauge Widnow
	local window = {
		imagePath 		= self.ViewPrefix..'/images/rpm-gauge-window.dds',
		width			= 0.22,
		height			= 0.1,	
		x_pos 			= 0.123,
		y_pos 			= 0.01,		
		disableCursor	= true,
	}
	-- Create Window
	self.rpmGaugeWindow = GraphicLayout(window);
	-- Add captions
	self.rpmGaugeWindowC0 = self.rpmGaugeWindow:addCaption('', 0.003, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC1 = self.rpmGaugeWindow:addCaption('10', 0.023, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC2 = self.rpmGaugeWindow:addCaption('20', 0.046, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC3 = self.rpmGaugeWindow:addCaption('30', 0.066, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC4 = self.rpmGaugeWindow:addCaption('40', 0.089, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC5 = self.rpmGaugeWindow:addCaption('50', 0.111, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC6 = self.rpmGaugeWindow:addCaption('60', 0.132, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC7 = self.rpmGaugeWindow:addCaption('70', 0.153, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC8 = self.rpmGaugeWindow:addCaption('80', 0.176, 0.015, 0.015, nil, true, nil, 'left', true);
	self.rpmGaugeWindowC9 = self.rpmGaugeWindow:addCaption('90', 0.197, 0.015, 0.015, nil, true, nil, 'left', true);
	-- Add Images
	self.rpmGaugeWindowTip = self.rpmGaugeWindow:addImage(self.ViewPrefix..'/images/rpm-tip.dds', 0.011, 0.049, self.rpmGaugeWindowTipMaxWidth, 0.027);		
	-- Init window
	addModEventListener(self.rpmGaugeWindow);	

	-- Add to LS 2011 mod list
	addModEventListener(self);
end;

function _:loadMap(name)
end;

function _:deleteMap()	
end;

function _:mouseEvent(posX, posY, isDown, isUp, button)
end;

function _:keyEvent(unicode, sym, modifier, isDown)
end;

function _:update(dt)
end;

function _:draw()
	if g_currentMission.controlledVehicle == nil then 
		self.rpmGaugeWindow:hide() 
	end;
end;