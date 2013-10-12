-------------------------------------------------------------+
-- Copyright © 2013 Rafa³ Miko³ajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- Gearbox Specialization
--
-- specjalizacja skrzyni biegów
------------------------------------------------------------*/

gearboxSpecialization = {};

function gearboxSpecialization.prerequisitesPresent(specializations)
	return true;
end;

function gearboxSpecialization:load(xmlFile)
	self.gearbox = {} -- kontener skrzyni biegów
	self.gearbox.view 	= Steerable.Gauges_View_gearbox; -- referencja do widoku wyœwietlacza biegów
	self.gearbox.model 	= Steerable.Gauges_Model_gearbox; -- referencja modelu skrzni biegów
	self.gearboxMultiplayerSynchro = SpecializationUtil.callSpecializationsFunction("gearboxMultiplayerSynchro");
	
	-- ustawienia skrzyni biegów
	self.gearbox.options = self.gearbox.model:getGearboxOptions();
	
	-- zmienne skrzyni biegów
	self.gearbox.gearboxMode		= self.gearbox.options.gearboxMode; -- rodzaj skrzyni (auto/manual)
	self.gearbox.driveMode			= 1; -- tryb biegów (drogowe/terenowe)
	self.gearbox.maxGear			= self.gearbox.options.maxGear; -- maksymalna iloœæ biegów
	self.gearbox.currentGear		= 'N'; -- aktualny bieg
	self.gearbox.clutchPedal		= false; -- wciœniête sprzêg³o
	self.gearbox.gearboxFinalRatio  = self.gearbox.options.gearboxFinalRatio; -- wspó³czynnik prze³o¿eñ skrzyni biegów
	self.gearbox.driveModeTerrainIncrease = nil; -- wspomanie biegów terenowych (nil/true)
	
	-- biblioteki
	self.gearbox.libs = {}
	self.gearbox.libs.Controls = self.gearbox.model.controlsLib;
	
	-- inne zmienne
	self.gearbox.other = {}
	self.gearbox.other.lastAccelerationInDraw 			= 0; -- ostatnie przespieszanie w funkcji draw() i update()
	self.gearbox.other.deceleration 					= false; -- zwalnianie
	self.gearbox.other.wheelsNotGroundContactNum		= 0; -- iloœæ kó³ oderwanych od ziemi	
	self.gearbox.other.wheelsNotGroundContactNumTick 	= 0; -- iloœæ kó³ oderwanych od ziemi w funckji updateTick()
	self.motor.lastMotorRpmForBrake 					= nil;
	self.gearbox.other.lastAccelerationForBrake			= 0;
	self.gearbox.other.neutralGearRPMprogress			= nil;
	self.gearbox.other.neutralGearReset					= false;
	self.gearbox.other.fallDownForce					= 0; -- si³a spadania na ziemie	
	self.gearbox.other.lastAccelerationHasGroundContact	= 0; -- ostatnia szybkoœæ gdy ko³a dotyka³y pod³o¿a
	
	-- oryginalne wartoœæ zmiennych pojazdu
	self.gearbox.originalValues = {}
	self.gearbox.originalValues.maxAccelerationSpeed				= self.maxAccelerationSpeed;
	self.gearbox.originalValues.motor								= {}
	self.gearbox.originalValues.motor.forwardGearRatios				= {}
	self.gearbox.originalValues.motor.forwardGearRatiosStandard		= {}
	self.gearbox.originalValues.motor.forwardGearRatios[3]			= self.motor.forwardGearRatios[3];
	self.gearbox.originalValues.motor.forwardGearRatiosStandard[3]	= self.motor.forwardGearRatios[3];
	self.gearbox.originalValues.motor.backwardGearRatio				= self.motor.backwardGearRatio;
	self.gearbox.originalValues.motor.transmissionEfficiency		= self.motor.transmissionEfficiency;
	self.gearbox.originalValues.downForce							= self.downForce;
end;

function gearboxSpecialization:readStream(streamId, connection)
end;

function gearboxSpecialization:writeStream(streamId, connection)
end;

function gearboxSpecialization:delete()
end;

function gearboxSpecialization:mouseEvent(posX, posY, isDown, isUp, button)
end;

function gearboxSpecialization:keyEvent(unicode, sym, modifier, isDown)
end;

function gearboxSpecialization:updateTick(dt)
	gearboxSpecialization.rpmPhysics(self, self.gearbox.libs.Controls); 
	gearboxSpecialization.speedPhysics(self);
	
	if self.isMotorStarted and self.isEntered then
		-- obliczanie innych zmiennych
		if self.gearbox.other.lastAccelerationInDraw>self.lastAcceleration then self.gearbox.other.deceleration = true
		else self.gearbox.other.deceleration = false end;
			
		self.gearbox.other.wheelsNotGroundContactNumTick = self.gearbox.other.wheelsNotGroundContactNum;		
	end;
	
	-- naprawa wstecznego na górce
	if self.isMotorStarted and self.isEntered and self.gearbox.currentGear == 'R' and self.gearbox.gearboxMode == 'manual' and self.movingDirection == 1 and not gearboxSpecialization.isAI(self) then 
		self.maxAccelerationSpeed 			= 0;
		self.motor.forwardGearRatios[3] 	= 0;
		self.motor.speedLevel				= 0;
		self.movingDirection 				= 0;
	end;
end;

function gearboxSpecialization:update(dt)	
	if self.isMotorStarted and self.isEntered then
		-- Szybsze obroty gdy pojazd oderwie siê od ziemi
		self.gearbox.other.wheelsNotGroundContactNum = 0;
		for key,wheel in pairs(self.wheels) do 
			if not wheel.hasGroundContact then
				self.gearbox.other.wheelsNotGroundContactNum = self.gearbox.other.wheelsNotGroundContactNum+1;
			end;
		end;
		if self.gearbox.other.wheelsNotGroundContactNum == 0 then self.gearbox.other.lastAccelerationHasGroundContact = self.lastAcceleration end; -- ostatnia prêdkoœæ gdy ko³a dotyka³y ziemi
		if self.gearbox.other.wheelsNotGroundContactNum == 0 and self.gearbox.other.wheelsNotGroundContactNumTick>0 then -- podczas upadku
			self.lastAcceleration = self.gearbox.other.lastAccelerationHasGroundContact*(1-self.gearbox.other.fallDownForce); -- przyspieszenie spada w trakcie upadku
			if self.lastAcceleration<0.1 then self.lastAcceleration = 0.1 end;
		elseif self.gearbox.other.wheelsNotGroundContactNum>0 then -- podczas oderwania od ziemi
			self.gearbox.other.fallDownForce = self.gearbox.other.fallDownForce+((0.001*self.gearbox.other.wheelsNotGroundContactNum)*(1+(0.045*self.downForce))); -- obliczanie si³y z jak¹ pojazd opada na ziemiê
			if -InputBinding.getDigitalInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE)>0 or -InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE)>0 then 
				self.lastAcceleration = self.lastAcceleration*(1+(0.01*self.gearbox.other.fallDownForce)); -- przyspieszenie wzrasta w trakcie lotu
				if self.lastAcceleration>1 then self.lastAcceleration = 1 end;			
			end;
		else 
			self.gearbox.other.fallDownForce = 0; -- si³a opadania na ziemiê równa zero
		end;
	end;

	gearboxSpecialization.gearboxPhysics(self);
	gearboxSpecialization.displayControls(self);
	
	if self.isMotorStarted and self.isEntered then
		--renderText(0.2, 0.2, 0.04, tostring(self.downForce));
		--renderText(0.2, 0.2, 0.04, tostring(self.movingDirection));
		--renderText(0.2, 0.2, 0.04, tostring(self.maxAccelerationSpeed));
		--renderText(0.2, 0.2, 0.04, tostring(self.motor.forwardGearRatios[3]));
		--WheelsUtil.updateWheelsPhysics(self, dt, currentSpeed, acceleration, doHandbrake, requiredDriveMode);
		--renderText(0.2, 0.2, 0.04, tostring(self.lastAcceleration));
		--renderText(0.2, 0.2, 0.04, tostring(self.wheels[1].axleSpeed));		
		--renderText(0.2, 0.2, 0.04, tostring(self.gearbox.other.deceleration));	
		--renderText(0.2, 0.7, 0.03, 'Bieg: '..tostring(self.gearbox.currentGear));
		--renderText(0.2, 0.6, 0.03, 'Rodzaj: '..tostring(self.gearbox.gearboxMode));
		--renderText(0.2, 0.5, 0.03, 'Max: '..tostring(self.gearbox.maxGear));
		--renderText(0.2, 0.4, 0.03, 'Tryb: '..tostring(self.gearbox.driveMode));
	end;
	
	self.reverseDriveSoundEnabled = true;
	self.gearbox.other.lastAccelerationInDraw = self.lastAcceleration;
	
	-- synchronizacja danych z multiplayer
	Steerable.Gauges_events.gearboxSpecializationEvent.sendEvent(self);
end;

function gearboxSpecialization:draw()
	if not gearboxSpecialization.isAI(self) and self.motor.speedLevel == 0 then 
		self.gearbox.view.GearsGaugeWindow:show(); -- poka¿ wyœwietlacz biegów na ekranie
	else 
		self.gearbox.view.GearsGaugeWindow:hide(); -- ukryj
	end;
end;

-- Fukcja sprawdza czy autopilot jest w³¹czony
function gearboxSpecialization.isAI(self)
	if self.isAITractorActivated ~= nil then
		return self.isAITractorActivated;
	elseif self.isAIThreshing ~= nil then
		return self.isAIThreshing;
	else return false end;
end;

-- Sterownik kontrolek
function gearboxSpecialization.displayControls(self)
	if self.isMotorStarted and self.isEntered then
		-- Fuel Light
		local FuelReserve = self.fuelCapacity*8/100;
		if FuelReserve>self.fuelFillLevel then
			self.gearbox.view.lightFuelOff.visible = false;
			self.gearbox.view.lightFuelOn.visible = true;			
		else 
			self.gearbox.view.lightFuelOff.visible = true;
			self.gearbox.view.lightFuelOn.visible = false;
		end;
		
		-- Battery Light
		if self.isMotorStarted  then
			self.gearbox.view.lightBatteryOff.visible = true;
			self.gearbox.view.lightBatteryOn.visible = false;	
		end;
		
		-- RPM Light
		local rpmTipSegment = self.motor.maxRpm[3]/9;
		if self.motor.lastMotorRpm>rpmTipSegment*8 then
			self.gearbox.view.rpmLightOff.visible = false;
			self.gearbox.view.rpmLightOn.visible	= true;
		else 
			self.gearbox.view.rpmLightOff.visible = true;
			self.gearbox.view.rpmLightOn.visible	= false;		
		end;
		-- Efekt "dygotania" licznika obrotów na odciêciu
		--[[if self.motor.speedLevel == 0 and self.motor.lastMotorRpm == self.motor.maxRpm[3] then
			self.motor.lastMotorRpm = rpmTipSegment*8.5;
		end;--]]		
	end;
end;

-- fizyka obrotów
function gearboxSpecialization.rpmPhysics(self, Controls)
	if self.isMotorStarted and self.isEntered and not gearboxSpecialization.isAI(self) and self.motor.speedLevel == 0 then
		--if this.gearboxSettings.gearboxMode == 'manual' then
			if self.motor.minRpm<150 then self.motor.minRpm = 150 end;
			
			if self.motor.speedLevel == 0 then
				local newRPM = 0;
				if self.motor.lastMotorRpmForBrake == nil then self.motor.lastMotorRpmForBrake = self.motor.minRpm end;
						
				
				if self.gearbox.other.neutralGearRPMprogress == nil then
					self.gearbox.other.neutralGearRPMprogress = Controls.Progress(self.motor.maxRpm[3], 0.0, self.motor, 'lastMotorRpm');
				end;			
				-- Neutral gear
				if self.gearbox.currentGear == 'N' then 
					if self.gearbox.other.neutralGearReset then 
						self.motor.lastMotorRpm = self.motor.minRpm;
						self.gearbox.other.neutralGearRPMprogress.lastValue = self.motor.minRpm;
					end;
					local acceleration = 0;
					if InputBinding.isAxisZero(-InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE)) then
						acceleration = -InputBinding.getDigitalInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE);
					else 
						acceleration = -InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE);
					end;
					self.gearbox.other.neutralGearRPMprogress:start();
					local targetValue = self.motor.maxRpm[3]*acceleration;
					if targetValue<self.motor.minRpm then targetValue = self.motor.minRpm-10 end;
					self.gearbox.other.neutralGearRPMprogress:setTargetValue(targetValue);
					if acceleration>0 then self.gearbox.other.neutralGearRPMprogress:setProgressSpeed(acceleration*10);
					else self.gearbox.other.neutralGearRPMprogress:setProgressSpeed(1.0) end;
					self.lastAcceleration = acceleration*0.5;
					if self.gearbox.other.neutralGearRPMprogress:getLastValue() ~= nil then self.motor.lastMotorRpm = self.gearbox.other.neutralGearRPMprogress:getLastValue() end;
					if self.motor.lastMotorRpm<self.motor.minRpm then self.motor.lastMotorRpm = self.motor.minRpm end;
					self.gearbox.other.neutralGearReset = false;
				-- Other gears
				else 
					self.gearbox.other.neutralGearReset = true;
					self.gearbox.other.neutralGearRPMprogress:stop();
					if self.lastAcceleration<0 and self.gearbox.gearboxMode == 'auto' then newRPM = -self.lastAcceleration*self.motor.maxRpm[3]; 
					else
						-- Brake
						if self.lastAcceleration<0 then
							if self.gearbox.currentGear == 'R' and self.wheels[1].axleSpeed>0 then 
								newRPM = self.lastAcceleration*self.motor.maxRpm[3];
								self.lastAcceleration = 0;
								self.motor.lastMotorRpmForBrake = self.motor.minRpm;
							else
								newRPM = (1-(-self.lastAcceleration))*self.motor.lastMotorRpmForBrake;
								self.gearbox.other.lastAccelerationForBrake = newRPM/self.motor.maxRpm[3];
								self.lastAcceleration = self.lastAcceleration*1.15;
							end;
						-- Acceleration
						else
							if self.gearbox.other.lastAccelerationForBrake>0 then 
								self.lastAcceleration = self.gearbox.other.lastAccelerationForBrake;
								self.gearbox.other.lastAccelerationForBrake = 0;
							end;
							newRPM = self.lastAcceleration*self.motor.maxRpm[3];
						end;
					end;
					
					if newRPM<self.motor.minRpm then newRPM = self.motor.minRpm
					elseif newRPM>self.motor.maxRpm[3] then newRPM = self.motor.maxRpm[3] end;	
					self.motor.lastMotorRpm = newRPM;
					if self.lastAcceleration>0 then self.motor.lastMotorRpmForBrake = self.motor.lastMotorRpm end;
				end;
				
				-- Clutch		;
				if self.gearbox.clutchPedal and tonumber(self.gearbox.currentGear) ~= nil then
					if tonumber(self.gearbox.currentGear)>=1 then						
						local gearboxFinalRatio = 1-self.gearbox.gearboxFinalRatio;
						if gearboxFinalRatio>0.65 then gearboxFinalRatio = 0.65
						elseif gearboxFinalRatio<0.35 then gearboxFinalRatio = 0.35 end;
						--local newAcceleration = gearboxFinalRatio+((1-gearboxFinalRatio)*(tonumber(self.gearbox.currentGear)-1)/self.gearbox.maxGear);
						local newAcceleration = 0.3+((1-gearboxFinalRatio)*(tonumber(self.gearbox.currentGear)-1)/self.gearbox.maxGear);
						if newAcceleration<self.lastAcceleration then
							self.lastAcceleration = newAcceleration;
						end;
					end;
				end;
			end;
	end;	
end;

-- fizyka szybkoœci
function gearboxSpecialization.speedPhysics(self)
	if self.isMotorStarted and self.isEntered then
		--if self.gearbox.gearboxMode == 'manual' then
			if self.motor.speedLevel == 0 then
				self.gearbox.originalValues.motor.forwardGearRatios[3] = self.gearbox.originalValues.motor.forwardGearRatiosStandard[3]*self.gearbox.gearboxFinalRatio*2;
				if self.gearbox.gearboxFinalRatio>0.5 and tonumber(self.gearbox.currentGear) ~= nil then
					self.motor.transmissionEfficiency = self.gearbox.originalValues.motor.transmissionEfficiency*(1+self.gearbox.gearboxFinalRatio/4)+(tonumber(self.gearbox.currentGear)/15);
				end;
			end;
		--end;
	end;	
end;

-- fizyka skrzyni
function gearboxSpecialization.gearboxPhysics(self)
	if self.isMotorStarted and self.isEntered and not gearboxSpecialization.isAI(self) and self.motor.speedLevel == 0 then
		-- obliczanie zmiennych
		if tonumber(self.gearbox.currentGear) ~= nil then
			if tonumber(self.gearbox.currentGear)>tonumber(self.gearbox.maxGear) then 
				self.gearbox.view:setGear(self.gearbox.maxGear);
			end;
		end;		
		
		if self.gearbox.gearboxMode == 'auto' then -- automat
			local acceleration = 0;
			if InputBinding.isAxisZero(-InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE)) then
				acceleration = -InputBinding.getDigitalInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE);
			else 
				acceleration = -InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE);
			end;
			if (self.movingDirection == -1 and self.wheels[1].axleSpeed<0) and self.gearbox.currentGear ~= 'R' then 
				self.gearbox.view:setGear('R');
			elseif (self.gearbox.currentGear == 'R' and self.wheels[1].axleSpeed>0) or (self.gearbox.currentGear == 'N' and acceleration>0) or (self.gearbox.currentGear == 'R' and acceleration>0) then
				self.gearbox.view:setGear(1);
			elseif self.wheels[1].axleSpeed == 0 then
				self.gearbox.view:setGear('N');
			end;
			
			-- Auto gear up
			local rpmTipSegment = self.motor.maxRpm[3]/9;
			if tonumber(self.gearbox.currentGear)~= nil and self.motor.lastMotorRpm>rpmTipSegment*8  then
				self.gearbox.view:upGear(true);
			end;
			-- Auto gear down
			if tonumber(self.gearbox.currentGear)~= nil then
				local onePartRPM = self.motor.maxRpm[3]/self.gearbox.maxGear;
				for i=2, self.gearbox.maxGear, 1 do 
					if tonumber(self.gearbox.currentGear)>i and self.motor.lastMotorRpm<onePartRPM*i and self.gearbox.other.deceleration then
						self.gearbox.view:downGear(true);
					end;
				end;
				if tonumber(self.gearbox.currentGear)>1 and self.motor.lastMotorRpm<=self.motor.minRpm then self.gearbox.view:setGear(1) end;
			end;			
		end;
		--elseif self.gearbox.gearboxMode == 'manual' then
			-- Acceleration Speed
			if self.gearbox.currentGear == 'N' then
				self.maxAccelerationSpeed 			= 0;
				self.motor.forwardGearRatios[3] 	= 0;
				self.motor.backwardGearRatio 		= 0;
				self.motor.speedLevel				= 0;
				self.movingDirection 				= 0;
			elseif self.gearbox.currentGear == 'R' then
				if self.gearbox.gearboxMode == 'manual' then
					self.maxAccelerationSpeed 			= self.gearbox.originalValues.maxAccelerationSpeed;
					self.motor.forwardGearRatios[3] 	= -self.gearbox.originalValues.motor.backwardGearRatio*0.5;
					if self.movingDirection == 1 then -- naprawa wstecznego na górce
						self.maxAccelerationSpeed 			= 0;
						self.motor.forwardGearRatios[3] 	= 0;
						self.motor.speedLevel				= 0;
						self.movingDirection 				= 0;
					else
						self.motor.backwardGearRatio 	= -self.gearbox.originalValues.motor.backwardGearRatio*0.5;
					end;
					self.movingDirection 				= 0;
					self.motor.speedLevel 				= 0;				
				elseif self.gearbox.gearboxMode == 'auto' then
					self.maxAccelerationSpeed 			= self.gearbox.originalValues.maxAccelerationSpeed;
					self.motor.forwardGearRatios[3] 	= -self.gearbox.originalValues.motor.backwardGearRatio*0.5;
					self.motor.backwardGearRatio 		= self.gearbox.originalValues.motor.backwardGearRatio*0.5;
				end;
			else
				if self.movingDirection == -1 then
					self.maxAccelerationSpeed = 0;
					self.motor.backwardGearRatio = 0;
				else
					self.movingDirection = 1;
					if tonumber(self.gearbox.currentGear) ~= nil then				
						for i=1,self.gearbox.maxGear do
							if tonumber(self.gearbox.currentGear) == i then
								local accelerationRatio = self.gearbox.gearboxFinalRatio*2;
								if accelerationRatio<0.35 then accelerationRatio = 0.35 end;
								--local minAcceleration = self.gearbox.originalValues.maxAccelerationSpeed/(i*accelerationRatio*2); -- regulacja przyspieszania
								--local minAcceleration = self.gearbox.originalValues.maxAccelerationSpeed/(i*accelerationRatio*0.5); -- regulacja przyspieszania
								local minAcceleration = self.gearbox.originalValues.maxAccelerationSpeed/(i*accelerationRatio*((self.wheels[1].netInfo.y+self.wheels[2].netInfo.y+self.wheels[3].netInfo.y+self.wheels[4].netInfo.y)*0.15)); -- regulacja przyspieszania: rozmiar kó³ ma wp³yw
								if self.gearbox.driveMode == 0 then minAcceleration = minAcceleration*1.3 end; -- szybsze przyspieszanie na biegach terenowych
								if self.lastAcceleration>0 then self.maxAccelerationSpeed = minAcceleration*(1-self.lastAcceleration)
								else self.maxAccelerationSpeed = minAcceleration end;

								local basePartRatio = 20*self.gearbox.originalValues.motor.forwardGearRatios[3]/100;
								local restPartRatio = self.gearbox.originalValues.motor.forwardGearRatios[3]-basePartRatio;
								local onePartRatio = restPartRatio/self.gearbox.maxGear;
								self.motor.forwardGearRatios[3] = basePartRatio+(onePartRatio*i); -- nowa wartoœæ prze³o¿eñ skrzyni
								if self.driveway ~= nil then -- jeœli dodano specjalizacje drivewayPhysic uwzglêdnij w prze³o¿eniach
									if self.gearbox.driveMode == 0 then -- dla biegów terenowych
										self.motor.forwardGearRatios[3] = self.motor.forwardGearRatios[3] - self.driveway.power*0.05;
										if self.motor.forwardGearRatios[3]<basePartRatio*2 then self.motor.forwardGearRatios[3] = basePartRatio*2 end;
									else -- pozosta³e
										self.motor.forwardGearRatios[3] = self.motor.forwardGearRatios[3] - self.driveway.power*1.5;
										if self.motor.forwardGearRatios[3]<basePartRatio then self.motor.forwardGearRatios[3] = basePartRatio end;
									end;
								end;
							end;
						end;						
					end;
				end;
			end;
		--end;
		if self.gearbox.driveMode == 1 then	-- ustawienia biegów drogowych
			self.downForce = self.gearbox.originalValues.downForce;
		elseif self.gearbox.driveMode == 0 then
			local fieldDriveRatio = self.motor.forwardGearRatios[3];
			-- ustawienia biegów terenowych
			if self.gearbox.driveModeTerrainIncrease == nil then 
				fieldDriveRatio = self.motor.forwardGearRatios[3]*0.77;
			else
				fieldDriveRatio = self.motor.forwardGearRatios[3]*0.9;
			end;
			self.motor.forwardGearRatios[3] = fieldDriveRatio;
		end;	
		
	-- autopilot
	elseif self.isMotorStarted and self.isEntered and gearboxSpecialization.isAI(self) then
		self.maxAccelerationSpeed 			= self.gearbox.originalValues.maxAccelerationSpeed;
		self.motor.forwardGearRatios[3] 	= self.gearbox.originalValues.motor.forwardGearRatios[3];
		self.motor.backwardGearRatio 		= self.gearbox.originalValues.motor.backwardGearRatio;
		self.motor.transmissionEfficiency   = self.gearbox.originalValues.motor.transmissionEfficiency;
		self.downForce 						= self.gearbox.originalValues.downForce;
	end;
end;

-- synchronizacja z multiplayerem
function gearboxSpecialization:gearboxMultiplayerSynchro(vehicle)
	self = vehicle;
end;
