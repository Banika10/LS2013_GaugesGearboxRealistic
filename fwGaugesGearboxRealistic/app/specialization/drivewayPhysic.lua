-------------------------------------------------------------+
-- Copyright © 2013 Rafa³ Miko³ajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Mod
-- Driveway Physics Specialization
--
-- Poprawiona fizyka w³asnoœci jezdnych:
-- 	* pojazdy podje¿dzaj¹ pod górê z wiêkszym trudem
------------------------------------------------------------*/

drivewayPhysic = {};

function drivewayPhysic.prerequisitesPresent(specializations)
	return true;
end;

function drivewayPhysic:load(xmlFile)
	self.driveway 				= {};
	function self.driveway.reductuion()
		local x, y, z, difference;
		x, y, z = getTranslation(self.rootNode);  -- wspó³rzêdne pojazdu
		
		self.driveway.yLast 		= y; -- ostatnia mierzona wysokoœæ
		self.driveway.yRatio 		= 0.0000001; -- co ile mierzyæ wysokoœæ
		self.driveway.yReflection 	= y-self.driveway.yRatio; -- wysokoœæ w punkcie zwrotnym
		self.driveway.power			= 0; -- "si³a podjazdu" - wartoœæ dodatnia oznacza jazdê pod górê, ujemna z góry
	end;
	
	self.driveway.reductuion();
end;

function drivewayPhysic:delete()
end;

function drivewayPhysic:mouseEvent(posX, posY, isDown, isUp, button)
end;

function drivewayPhysic:keyEvent(unicode, sym, modifier, isDown)
end;

function drivewayPhysic:update(dt)
	if self:getIsActive() then
		local x, y, z, difference;
		x, y, z = getTranslation(self.rootNode);  -- wspó³rzêdne pojazdu
		difference = y-self.driveway.yLast;
		
		if difference>self.driveway.yRatio then -- Jazda pod górê
			self.driveway.yLast = y;
			if self.driveway.power<0 then self.driveway.yReflection = y-self.driveway.yRatio end;
		elseif difference<-self.driveway.yRatio then -- Jazda z górki
			self.driveway.yLast = y;
			if self.driveway.power>0 then self.driveway.yReflection = y+self.driveway.yRatio end;
		end;
		
		self.driveway.power = self.driveway.yLast - self.driveway.yReflection; -- obliczanie si³y
		if self.driveway.power<0 then self.driveway.power = self.driveway.power*0.01
		else self.driveway.power = self.driveway.power*0.4 end; 
	end;
end;

function drivewayPhysic:updateTick(dt)
end;

function drivewayPhysic:draw()
end;