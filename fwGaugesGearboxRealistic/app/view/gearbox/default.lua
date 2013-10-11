-------------------------------------------------------------+
-- Copyright © 2012-2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- Gearbox View
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_View_gearbox';
local _ = newclass(name, View);
_G[name] = _;

function _:init()
end;

function _:load()	
	self.model 				= Mods:getRegistry(self.ViewPrefix, 'Model_gearbox');
	self.controller 		= self:getController();
	self.input 				= Mods:getRegistry(self.ViewPrefix, 'input');
	self.config 			= Mods:getRegistry(self.ViewPrefix, 'config');
	self.gearbox 			= nil;
	
	-- Gears Gauge Widnow
	local window = {
		imagePath 		= self.ViewPrefix..'/images/gears-gauge-window.dds',
		width			= 0.11,
		height			= 0.1,	
		x_pos 			= 0.01,
		y_pos 			= 0.01,		
		disableCursor	= true,
	}
	-- Create Window
	self.GearsGaugeWindow = GraphicLayout(window);
	-- Add captions
	self.gearboxModeCaption = self.GearsGaugeWindow:addCaption('manual', 0.008, 0.075, 0.015, nil, true, nil, 'left', true);	
	-- Add Images
	-- Gears
	local gear = {
		width			= 0.024,
		height			= 0.045,	
		x_pos 			= 0.042,
		y_pos 			= 0.026,	
	}
	self.GearD = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/d.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.GearN = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/n.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.GearR = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/r.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear1 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/1.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear2 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/2.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear3 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/3.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear4 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/4.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear5 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/5.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear6 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/6.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear7 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/7.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear8 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/8.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	self.Gear9 = self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/gears/9.dds', gear.x_pos, gear.y_pos, gear.width, gear.height);	
	-- RPM Light
	self.rpmLightOff 	= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/rpm-light-off.dds', 0.014, 0.011, 0.010, 0.015);
	self.rpmLightOn 	= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/rpm-light-on.dds', 0.014, 0.011, 0.010, 0.015);
	self.rpmLightOn.visible = false;
	--self.rpmLightOn.visible = false;
	-- Drive Mode
	self.lightRoad 		= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/drive-road.dds', 0.01, 0.035, 0.02, 0.028);
	self.lightField 	= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/drive-field.dds', 0.01, 0.035, 0.02, 0.028);
	self.lightField.visible = false;
	-- Lights 
	self.lightFuelOff 	= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/light-fuel-off.dds', 0.08, 0.028, 0.014, 0.022);
	self.lightFuelOn 	= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/light-fuel-on.dds', 0.08, 0.028, 0.014, 0.022);
	self.lightFuelOn.visible = false;
	self.lightBatteryOff 	= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/light-battery-off.dds', 0.077, 0.055, 0.02, 0.016);
	self.lightBatteryOn 	= self.GearsGaugeWindow:addImage(self.ViewPrefix..'/images/light-battery-on.dds', 0.077, 0.055, 0.02, 0.016);
	-- Init window
	addModEventListener(self.GearsGaugeWindow);		
	
	self:hideGears();
	self.GearN.visible = true;

	-- Add to mod list
	addModEventListener(self);
end;

function _:loadGearbox(gearbox)
	if gearbox ~= nil then
		self.gearbox = gearbox;
	end;
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
	if g_currentMission.controlledVehicle ~= nil then 
		g_currentMission:addExtraPrintText(self.i18n:get('input.startEngine')..': '..self.input:getActionKeyName('input.startEngine'));
	end;

	if g_currentMission.controlledVehicle ~= nil then 
		-- resetowanie stanu wyświetlacza
		self:loadGearbox(g_currentMission.controlledVehicle.gearbox);
		self:hideGears();
		self['Gear'..tostring(g_currentMission.controlledVehicle.gearbox.currentGear)].visible = true;
		if g_currentMission.controlledVehicle.gearbox.driveMode == 1 then
			self.lightRoad.visible = true;
			self.lightField.visible = false;
		elseif g_currentMission.controlledVehicle.gearbox.driveMode == 0 then
			self.lightRoad.visible = false;
			self.lightField.visible = true;
		end;		
		self.gearboxModeCaption.text = g_currentMission.controlledVehicle.gearbox.gearboxMode;
		
		if g_currentMission.controlledVehicle.isMotorStarted and g_currentMission.controlledVehicle.isEntered then
			-- Key Actions
			if self.input:getAction('input.upGear') then
				self:upGear();
			end;
			if self.input:getAction('input.downGear') then
				self:downGear();
			end;
			if self.input:getAction('input.gearN') then
				self:setGear('N');
			end;
			if self.input:getAction('input.gearR') then
				self:setGear('R');
			end;
			for i=1,self.gearbox.maxGear do
				if self.input:getAction('input.gear'..tostring(i)) then
					self:setGear(i);
				end;
			end;
			if self.input:getAction('input.changeGearboxMode') then
				if self.gearbox.gearboxMode == 'manual' then 
					self.gearbox.gearboxMode = 'auto';
					--[[self.lightRoad.visible = true;
					self.lightField.visible = false;
					self.gearbox.driveMode = 1;--]]
				elseif self.gearbox.gearboxMode == 'auto' then
					self.gearbox.gearboxMode = 'manual';
				end;
				self.gearboxModeCaption.text = self.gearbox.gearboxMode;
				--[[self.config:setValue('config.gearboxMode', self.gearbox.gearboxMode, 'string');
				self.config:save();	--]]	
			end;
			if self.input:getAction('input.changeDriveMode') then
				--if self.gearbox.gearboxMode == 'manual' then
					if self.gearbox.driveMode == 1 then
						self.lightRoad.visible = false;
						self.lightField.visible = true;
						self.gearbox.driveMode = 0;
					elseif self.gearbox.driveMode == 0 then
						self.lightRoad.visible = true;
						self.lightField.visible = false;
						self.gearbox.driveMode = 1;
					end;
				--end;
			end;
		end;
	end;
end;

function _:draw()
	if g_currentMission.controlledVehicle == nil then self.GearsGaugeWindow:hide() end;
	self.lightBatteryOn.visible = true;	
	self.lightBatteryOff.visible = false;
end;

-- Gears Functions
function _:hideGears()
	self.GearD.visible = false;
	self.GearN.visible = false;
	self.GearR.visible = false;
	self.Gear1.visible = false;	
	self.Gear2.visible = false;	
	self.Gear3.visible = false;	
	self.Gear4.visible = false;
	self.Gear5.visible = false;	
	self.Gear6.visible = false;
	self.Gear7.visible = false;
	self.Gear8.visible = false;	
	self.Gear9.visible = false;	
end;

function _:clutchPedal()
	self.gearbox.clutchPedal = false;
	self:hideGears();
	self['Gear'..self.gearbox.currentGear].visible = true;
end;

function _:setGear(gear, nosound)
	if not self.gearbox.clutchPedal then		
		local audioGearDown = createSample("gearDown");
		loadSample(audioGearDown, __DIR_GAME_MOD__..self.ViewPrefix..'/audio/gearchng.wav', false);
		local audioGearUp = createSample("gearUp");
		loadSample(audioGearUp, __DIR_GAME_MOD__..self.ViewPrefix..'/audio/gearchn3.wav', false);
		local audioGearTime = 1000;
		local audioGearVolume = 0.7;
	
		local currentGear = self.gearbox.currentGear;
		local gear = string.upper(tostring(gear));
		local numCurrentGear = Utils.getNoNil(tonumber(currentGear), 0);
		local numGear = Utils.getNoNil(tonumber(gear), 0);
		if currentGear ~= gear then
			if self['Gear'..gear] ~= nil then
				self:hideGears();
				if self.gearbox.gearboxMode == 'auto' or gear == 'R' or gear == 'N' then self['Gear'..gear].visible = true;
				else self.GearN.visible = true end;
				self.gearbox.currentGear = gear;
				
				if numGear<numCurrentGear then 
					if nosound == nil then playSample(audioGearDown, 1, audioGearVolume, audioGearTime) end;				
					local timerId = addTimer(50, 'clutchPedal', self);
				else 
					if gear == 'R' then 
						if currentGear ~= 'R' and nosound == nil then playSample(audioGearDown, 1, audioGearVolume, audioGearTime) end;
					else 
						if nosound == nil then playSample(audioGearUp, 1, audioGearVolume, audioGearTime) end;
					end;
					local timerId = addTimer(500, 'clutchPedal', self);
				end;
				self.gearbox.clutchPedal = true;			
			end;
		end;
	end;
end;

function _:upGear(allowAuto)
	if self.gearbox.gearboxMode == 'manual' or allowAuto then
		local currentGear = self.gearbox.currentGear;
		if currentGear == 'R' then  
			self:setGear('N');
		elseif currentGear == 'N' or currentGear == 'D' then
			self:setGear(1);
		else 
			currentGear = tonumber(currentGear);
			if currentGear<self.gearbox.maxGear then
				self:setGear(currentGear+1);				
			end;
		end;
	end;
end;

function _:downGear(allowAuto)
	if self.gearbox.gearboxMode == 'manual' or allowAuto then
		local currentGear = self.gearbox.currentGear;
		if currentGear == 'N' or currentGear == 'D' or currentGear == 'R' then
			self:setGear('R');
		elseif currentGear == '1' then
			self:setGear('N');
		else 
			currentGear = tonumber(currentGear);
			self:setGear(currentGear-1);				
		end;
		
		-- Akcja redukcji w specjalizacji drivewayPhysics
		if g_currentMission.controlledVehicle ~= nil then 
			if g_currentMission.controlledVehicle.driveway ~= nil then
				g_currentMission.controlledVehicle.driveway.reductuion();
			end;
		end;
	end;
end;

