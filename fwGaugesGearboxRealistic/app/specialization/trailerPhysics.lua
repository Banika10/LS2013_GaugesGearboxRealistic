-------------------------------------------------------------+
-- Copyright © 2013 Rafa³ Miko³ajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Mod
-- Trailer Physics Specialization
--
-- Poprawiona fizyka przyczepy:
-- 	* ci¹gnik jedzie wolniej pod wp³ywem ciê¿aru przyczepy
--	* przyczepa opada pod wp³ywem ciê¿aru ³adunku 
------------------------------------------------------------*/

trailerPhysics = {};

function trailerPhysics.prerequisitesPresent(specializations)
	return true;
end;

function trailerPhysics:load(xmlFile)
	self.trailers = {}
	self.getTrailers = SpecializationUtil.callSpecializationsFunction("getTrailers");
	self.downForceMax = self.downForce;
end;

function trailerPhysics:delete()

end;

function trailerPhysics:mouseEvent(posX, posY, isDown, isUp, button)
end;

function trailerPhysics:keyEvent(unicode, sym, modifier, isDown)
end;

function trailerPhysics:update(dt)
	if self:getIsActive() then
		self:getTrailers(self.attachedImplements); -- zliczanie przyczep
		if self.trailers ~= nil then
			local driveMode = self.gearbox.driveMode; -- drogowe czy terenowe
			local trailersNum = table.getn(self.trailers); -- liczba przyczep
			local trailersWeight = 0; -- ca³kowita waga pustych przyczep
			if trailersNum>0 then
				for _, trailer in pairs(self.trailers) do  
					trailersWeight = trailersWeight+trailer.object.emptyMass;
					
					--[[ Nowa si³a docisku przyczepy --]]
					local difference = trailer.object.currentMass-trailer.object.emptyMass;
					if difference>0 then
						if driveMode==0 then
							--trailer.object.downForce = 10*(math.pow(1+difference, 2));
							if trailer.object.downForce>20 then 
								self.gearbox.driveModeTerrainIncrease = true;
							else 
								self.gearbox.driveModeTerrainIncrease = nil;
							end;
						--else
						end;
						trailer.object.downForce = 10*(math.pow(1+difference, 3)); -- nowy docisk zale¿y od wagi przyczepy z obci¹¿eniem
					else
						self.gearbox.driveModeTerrainIncrease = nil;
						trailer.object.downForce = 10;
					end;
				end;
				if trailersWeight>0 then 
					--[[ Nowa si³a docisku pojazdu --]]
					if driveMode==0 then -- na terenowych
						self.downForce = self.downForceMax/1.5; 
					else
						self.downForce = (self.downForceMax/(1.5+trailersWeight))-5;  -- nowy docisk zale¿y od ca³kowitej wagi pustych przyczep
					end;					
				end;
			else 
				self.downForce = self.downForceMax; -- jeœli brak przyczep ustaw domyœln¹ wartoœæ docisku
				self.gearbox.driveModeTerrainIncrease = nil;
			end;
		end;
	end;
end;

function trailerPhysics:updateTick(dt)
end;

function trailerPhysics:draw()
end;

function trailerPhysics:getTrailers(attachedImplements, recursive)
	if recursive==nil then self.trailers = {} end;
	if attachedImplements ~= nil and table.getn(attachedImplements)>0 then
		for _, trailer in pairs(attachedImplements) do  
			if trailer.object ~= nil then
				if trailer.object.currentMass ~= nil and trailer.object.emptyMass ~= nil and trailer.object.downForce ~= nil then
					table.insert(self.trailers, trailer);
					self:getTrailers(trailer.object.attachedImplements, true);
				end;
			end;
		end;	
	end;
end;

