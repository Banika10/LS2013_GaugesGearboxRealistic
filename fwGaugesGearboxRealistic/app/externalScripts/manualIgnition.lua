--
-- manualIgnition
-- Specialization for manual motor ignition
--
-- @v1: Templaer - 01 May   2009
-- @v2: Henly20  - 24 April 2012
-- 
-- @author:    	Xentro (www.ls-uk.info)(Marcus@Xentro.se)
-- @version:    v3.01
-- @date:       2012-10-26
-- 
--
--[[
Disable manualIgnition for your mod.
<manualIgnition deactivate="true" />

xml for dash lights, add as many as you want. (add <dashLight index="" /> after comment. (line 21))
<dashLights>
	<dashLight index="" />
	<!-- add more after this line if you want more dash lights -->
	
</dashLights>

Replace x y z with you rotation value.
off = engine off
on = engine on
start = this is the stage where key is on "start motor"
<key index="" off="x y z" on="x y z" start="x y z" />

-- other options --

preHeatStart - This will stop user from starting while preHeatHud is displayed.
preHeat - How long the pre heat mode should be.

<manualIgnition preHeatStart="false" preHeat="1400"  />

idleFuelUsage - Fuel usage when not moving and motor is on, in percentage.
movingFuelUsage - Add some fuel usage when moving, in percentage.

<fuelUsage idleFuelUsage="10" movingFuelUsage="40"  />
]]--

manualIgnition = {};
manualIgnition.stat = {};

function manualIgnition.prerequisitesPresent(specializations)
	return true;
end;

function manualIgnition:load(xmlFile)
	self.deactivateMI = Utils.getNoNil(getXMLBool(xmlFile, "vehicle.manualIgnition#deactivate"), false);
	
	if not self.deactivateMI then
		self.setManualIgnitionMode = SpecializationUtil.callSpecializationsFunction("setManualIgnitionMode");
		
		if self.motorStopSound ~= nil then
			self.motorStopSoundNew = self.motorStopSound;
			 self.motorStopSoundVolumeNew =  self.motorStopSoundVolume;
		end;
		
		self.playedMotorStopSoundNew = true;
		self.ignitionKey = false;
		self.allowedIgnition = false;
		self.isMotorStarted = false;
		
		self.motorStopSoundVolume = 0;
		self.ignitionMode = 0;

		self.dashLights = {};
		self.dashLights.activated = false;
		self.dashLights.table = {};
		local i = 0;
		while true do
			local path = string.format("vehicle.dashLights.dashLight(%d)", i);
			if not hasXMLProperty(xmlFile, path) then break; end;
			
			local index = getXMLString(xmlFile, path .. "#index")
			if index ~= nil then
				local entry = {};
				entry.node = Utils.indexToObject(self.components, index);
				
				table.insert(self.dashLights.table, entry);
				i = i + 1;
			end;		
		end;
		
		local keyPath = "vehicle.key";
		self.key = {};
		self.key.mode = 0;
		self.key.lastMode = 0;
		if hasXMLProperty(xmlFile, keyPath) then
			local index = getXMLString(xmlFile, keyPath .. "#index")
			if index ~= nil then
				self.key.node = Utils.indexToObject(self.components, index);
				
				local off = Utils.getRadiansFromString(getXMLString(xmlFile, keyPath .. "#off"), 3);
				local on = Utils.getRadiansFromString(getXMLString(xmlFile, keyPath .. "#on"), 3);
				local start = Utils.getRadiansFromString(getXMLString(xmlFile, keyPath .. "#start"), 3);
				
				if off == nil then
					local x, y, z = getRotation(self.key.node);
					off = {x, y, z};
				end;
				
				if on ~= nil and start ~= nil then
					self.key.rot = {};
					self.key.rot['off'] = off;
					self.key.rot['on'] = on;
					self.key.rot['start'] = start;
				else
					print('Error: <key> is missing a value for on="x y z" or starting="x y z" ');
				end;
			end;
		end;
	
		self.preHeatTM = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.manualIgnition#preHeat"), 1400);
		self.preHeatS = Utils.getNoNil(getXMLBool(xmlFile, "vehicle.manualIgnition#preHeatStart"), true);
		self.preHeatT = 0
		
		self.idleFuelUsage = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.fuelUsage#idleFuelUsage"), 10) / 100;
		self.movingFuelUsage = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.fuelUsage#movingFuelUsage"), 40) / 100;
		
		self.mpwt = 0;
		self.mpwtm = "";
	end;
end;

function manualIgnition:delete()
	if not self.deactivateMI then
		if Steerable.preHeatOverlat ~= nil then
			Steerable.preHeatOverlay:delete();
		end;
	end;
end;

function manualIgnition:readStream(streamId, connection)
	if not self.deactivateMI then
		self:setManualIgnitionMode(streamReadInt8(streamId), true);
	end;
end;

function manualIgnition:writeStream(streamId, connection)
	if not self.deactivateMI then
		streamWriteInt8(streamId, self.ignitionMode);
	end;
end;

function manualIgnition:mouseEvent(posX, posY, isDown, isUp, button)
end;

function manualIgnition:keyEvent(unicode, sym, modifier, isDown)
end;

function manualIgnition:update(dt)	
	if not self.deactivateMI then
		if self:getIsActive() and self:getIsActiveForSound() and g_gui.currentGuiName == "" and self.isClient then
			if InputBinding.hasEvent(InputBinding.MANUAL_IGNITION_KEY) then
				if self.ignitionMode > 2 then
					self.ignitionMode = 0;
				end;
				if self.ignitionMode ~= 1 or (self.ignitionMode == 1 and (self.preHeatT == 0 and not self.preHeatS) or (self.preHeatS and self.preHeatT >= 0)) then
					self:setManualIgnitionMode(math.abs(self.ignitionMode + 1));
				else
					self.mpwt = self.time + 1000;
					self.mpwtm = Steerable.MANUAL_IGNITION_ERROR2;
				end;
			end;
			
			if InputBinding.isPressed(InputBinding.MANUAL_IGNITION_KEY) and self.ignitionMode == 2 then
				self.key.mode = 2;
			else		
				if self.isMotorStarted then
					self.key.mode = 1;
				end;
			end;
			
			if (self.axisForward < -0.5 or self.axisForward > 0.5) and self.ignitionMode == 0 then
				self.mpwt = self.time + 800;
				self.mpwtm = Steerable.MANUAL_IGNITION_ERROR;
			end;
		end;
	end;
 end;

function manualIgnition:updateTick(dt)
	if not self.deactivateMI then
		if self:getIsActive() then
			local key = self.key;
			if key.mode ~= key.lastMode then
				if key.rot ~= nil then
					if key.mode == 1 then
						setRotation(key.node, key.rot['on'][1], key.rot['on'][2], key.rot['on'][3]);
					elseif key.mode == 2 then
						setRotation(key.node, key.rot['start'][1], key.rot['start'][2], key.rot['start'][3]);
					else
						setRotation(key.node, key.rot['off'][1], key.rot['off'][2], key.rot['off'][3]);
					end;
				end;
				key.lastMode = key.mode;
			end;
			
			if self.ignitionMode == 1 then
				if self.preHeatT > 0 then
					self.preHeatT = math.max(self.preHeatT - dt, 0);
				end;
			else
				if self.preHeatT ~= self.preHeatTM then
					self.preHeatT = self.preHeatTM;
				end;
			end;
		end;
		
		local stopAI = false;
		if not self:getIsHired() then
			if self.ignitionKey and self.allowedIgnition then
				self:startMotor(true);
				self.deactivateOnLeave = false;
				Utils.setEmittingState(self.exhaustParticleSystems, true)
				self.allowedIgnition = false;
			elseif not self.ignitionKey and self.allowedIgnition then
				self:stopMotor(true);
				self.deactivateOnLeave = true;
				self.allowedIgnition = false;
			end;

			if not self.playedMotorStopSoundNew and self.motorStopSoundNew ~= nil then
				playSample(self.motorStopSoundNew, 1, self.motorStopSoundVolumeNew, 0);
				self.playedMotorStopSoundNew = true;
			end;
			
		elseif not self.ignitionKey and not self.deactivateOnLeave then
			stopAI = true;
		end;
		
		if self.ignitionMode ~= 2 then
			self:onDeactivate(true);
			self:onDeactivateSounds(true);
			stopAI = true;
		end;
		
		if self.isBroken or (not self.ignitionKey and self.ignitionMode == 2) then
			stopAI = true;
			if self.ignitionMode ~= 0 then
				self:setManualIgnitionMode(0);
			end;
		elseif self.fuelFillLevel == 0 then
			stopAI = true;
			if self.ignitionMode ~= 1 then
				self:setManualIgnitionMode(1);
			end;
		end;
		
		if stopAI then
			if self:getIsHired() then
				if SpecializationUtil.hasSpecialization(AICombine, self.specializations) then
					AICombine.stopAIThreshing(self, true);
				end;
				if SpecializationUtil.hasSpecialization(AITractor, self.specializations) then
					AITractor.stopAITractor(self, true);
				end;
			end;
		end;
		
		for _, v in pairs(self.dashLights.table) do
			if v ~= nil and getVisibility(v.node) ~= self.dashLights.activated then
				setVisibility(v.node, self.dashLights.activated);
			end;
		end;
		
        if self.isMotorStarted and not self:getIsHired() and self.isServer then
			local fuelUsed = self.fuelUsage * self.idleFuelUsage;
			if self:getIsActive() and self.movingDirection ~= 0 then
				fuelUsed = self.fuelUsage * self.movingFuelUsage;
			end;
			
			self:setFuelFillLevel(self.fuelFillLevel - fuelUsed);
			g_currentMission.missionStats.fuelUsageTotal = g_currentMission.missionStats.fuelUsageTotal + fuelUsed;
			g_currentMission.missionStats.fuelUsageSession = g_currentMission.missionStats.fuelUsageSession + fuelUsed;
        end;
	end;
end;

function manualIgnition:onLeave()
	if not self.deactivateMI then
		if not self.deactivateOnLeave then
			Utils.setEmittingState(self.exhaustParticleSystems, true)
			self.allowedIgnition = false;
			self.isMotorStarted = true;
			self.ignitionKey = true;

			self.lastAcceleration = 0;
			if self.isServer then
				for k,wheel in pairs(self.wheels) do
					setWheelShapeProps(wheel.node, wheel.wheelShape, 0, self.motor.brakeForce, 0);
				end;
			end;
		else
			self.allowedIgnition = false;
			self.ignitionKey = false;
			self.key.mode = 0;
		end;
	end;
end;

function manualIgnition:onEnter()
	if not self.deactivateMI then
		if not self.ignitionKey then
			self.isMotorStarted = false;
			Motorized.stopSounds(self);
			Utils.setEmittingState(self.exhaustParticleSystems, false)
		else
			if self.ignitionMode == 2 then
				self.allowedIgnition = true;
				self.ignitionKey = true;
				self.key.mode = 1;
			end;	
		end;
	end;
end;

function manualIgnition:draw()
	if not self.deactivateMI and self.isClient then
		if self.ignitionMode == 0 then
			g_currentMission:addHelpButtonText(Steerable.MANUAL_IGNITION_START, InputBinding.MANUAL_IGNITION_KEY);
		elseif self.ignitionMode == 1 then
			if self.preHeatT > 0 then
				Steerable.preHeatOverlay:render();
				g_currentMission:addHelpButtonText(Steerable.MANUAL_IGNITION_PRE, InputBinding.MANUAL_IGNITION_KEY);
			else
				g_currentMission:addHelpButtonText(Steerable.MANUAL_IGNITION_START, InputBinding.MANUAL_IGNITION_KEY);
			end;
		end;
		
		if self.mpwt > self.time then
			g_currentMission:addWarning(self.mpwtm, 0.018, 0.033);
		end;
	end;
end;

function manualIgnition:setManualIgnitionMode(ignition, noEventSend)
	manualIgnitionEvent.sendEvent(self, ignition, noEventSend);

	self.ignitionMode = ignition;
	self.key.mode = 0;
    self.lastAcceleration = 0;
	
    self.ignitionKey = false;
	self:stopMotor(true);
	self.allowedIgnition = false;
	self.deactivateOnLeave = true;
	self.dashLights.activated = false;
	
	if self.ignitionMode == 1 then
		self.key.mode = 1;
		self.dashLights.activated = true;
	elseif self.ignitionMode == 2 then
		self.ignitionKey = true;
		self.key.mode = 1;
		self.allowedIgnition = true;
	elseif self.ignitionMode > 2 then
		self.ignitionMode = 0;
		self.playedMotorStopSoundNew = false;
	end;
	
    if self.isServer and self.ignitionMode ~= 2 then
		for k,wheel in pairs(self.wheels) do
			setWheelShapeProps(wheel.node, wheel.wheelShape, 0, self.motor.brakeForce, 0);
		end;
    end;
end;


manualIgnitionEvent = {};
manualIgnitionEvent_mt = Class(manualIgnitionEvent, Event);

InitEventClass(manualIgnitionEvent, "manualIgnitionEvent");

function manualIgnitionEvent:emptyNew()
    local self = Event:new(manualIgnitionEvent_mt);
    self.className="manualIgnitionEvent";
    return self;
end;

function manualIgnitionEvent:new(vehicle, ignition)
    local self = manualIgnitionEvent:emptyNew()
    self.vehicle = vehicle;
	self.ignition = ignition;
    return self;
end;

function manualIgnitionEvent:readStream(streamId, connection)
    local id = streamReadInt32(streamId);
	self.ignition = streamReadInt8(streamId);
    self.vehicle = networkGetObject(id);
    self:run(connection);
end;

function manualIgnitionEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteInt8(streamId, self.ignition);
end;

function manualIgnitionEvent:run(connection)
	self.vehicle:setManualIgnitionMode(self.ignition, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(manualIgnitionEvent:new(self.vehicle, self.ignition), nil, connection, self.object);
	end;
end;
function manualIgnitionEvent.sendEvent(vehicle, ignition, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(manualIgnitionEvent:new(vehicle, ignition), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(manualIgnitionEvent:new(vehicle, ignition));
		end;
	end;
end;

