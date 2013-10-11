-------------------------------------------------------------+
-- Copyright © 2012 Rafa³ Miko³ajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gearbox Mod
-- Test View
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_View_Test';
local _ = newclass(name, View);
_G[name] = _;

function _:init()
end;

function _:load()	
	addModEventListener(self);	
end;

function _:loadMap(name)
end;

function _:deleteMap()	
end;

function _:mouseEvent(posX, posY, isDown, isUp, button)
end;

function _:keyEvent(unicode, sym, modifier, isDown)
	if isDown and sym == Input.KEY_insert then
		--saveFile("test.txt", self.ViewPrefix, table.show(g_currentMission.vehicles), 0);	
		--saveFile("test2.txt", self.ViewPrefix, table.show(StoreItemsUtil), 0);	
		--saveFile("test3.txt", self.ViewPrefix, table.show(g_shopScreen), 0);	
		--g_currentMission.missionStats.money = g_currentMission.missionStats.money + 100000;
		--[[for index,vehicle in pairs(g_currentMission.vehicles) do
			if vehicle.typeName == 'Zetor16145_v2.ZTS16145' then
				--vehicle:onLeave(); --wyrzuca z pojazdu
				--vehicle:stopMotor();  --wy³acza silnik
			end;
		end;--]]
		
		-- Delete all shop items
		--[[for i=1,table.getn(StoreItemsUtil.storeItems) do 
			table.remove(StoreItemsUtil.storeItems);
		end;
				
		-- Buy Button
		local storeItem = {
			xmlFilename = "C:/Users/Test/Documents/My Games/FarmingSimulator2011/mods/Zetor16145_v2/ZTS_16145.xml",
			price		= 0
		}--]]
		--g_shopScreen:onBuyClick(storeItem, true);
			
		-- Zmiana pozycji pojazdów sterowalnych
		--[[for index,steerable in pairs(g_currentMission.steerables) do
			local rootX, rootY, rootZ;
			for comIndex,component in pairs(steerable.components) do
				if comIndex == 1 then
					-- Wczytanie starej pozycji
					rootX, rootY, rootZ = getTranslation(component.node);
				end;
				print(tostring(rootX));
				-- Nadanie nowej pozycji (i3d node, x, y, z)
				setTranslation(component.node, 0, 0, 0);
			end;
		end;--]]
		
		-- Zmiana pozycji wszystkich pojazdów w tym niesterowanlnych
		--[[for index,vehicle in pairs(g_currentMission.vehicles) do
			for comIndex,component in pairs(vehicle.components) do
				-- Nadanie nowej pozycji (i3d node, x, y, z)
				setTranslation(component.node, 0, 0, 0);
			end;
		end;--]]
		
		-- Usuwanie pojazdów z listy sterowalnych
		--[[for i=1,table.getn(g_currentMission.steerables) do 
			table.remove(g_currentMission.steerables);
		end;--]]
		
		-- Kasowanie pojazdów
		--[[local VehicleNodesTable = {}
		for index,vehicle in pairs(g_currentMission.vehicles) do		
			for comIndex,component in pairs(vehicle.components) do
				table.insert(VehicleNodesTable, component.node);				
			end;
		end;--]]
		--for i=1,table.getn(VehicleNodesTable) do 
			--[[ Not work with Vehicle
			local object = g_currentMission:getNodeObject(VehicleNodesTable[i]);
			if object ~= nil and object:isa(Vehicle) then
				object:delete();
			end;--]]
			--local vehicle = g_currentMission.nodeToVehicle[VehicleNodesTable[i]];
			--[[if vehicle ~= nil then
				g_currentMission:removeVehicle(vehicle);
			end;		
		end;--]]	
		
		-- Dodawania specjalizacji do pojazdu	
		--[[for index,vehicle in pairs(g_currentMission.vehicles) do
			table.insert(vehicle.specializations, rpmLimiter);
		end;--]]
		
		print('***** OK');
	end;
end;

function _:update(dt)	
end;

function _:draw()
	renderText(0.2, 0.2, 0.04, 'TEST');
end;