-------------------------------------------------------------+
-- Copyright © 2013-2013 Rafał Mikołajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- gearbox model
------------------------------------------------------------*/

local name = 'fwGaugesGearboxRealistic_Model_gearbox';
local _ = newclass(name, Model);
_G[name] = _;

function _:init()
end;

function _:load()
	-- plik konfiguracyjny
	self.config = Mods:getRegistry(self.ModelPrefix, 'config');	
	
	-- biblioteka kontrolek
	self.controlsLib = Controls;
	
	-- opcje skrzyni biegów
	self.gearboxOptions = {}
	self.gearboxOptions.userOptionsEnable	= false;
	self.gearboxOptions.gearboxMode 		= 'manual';
	self.gearboxOptions.maxGear 			= 4;
	self.gearboxOptions.gearboxFinalRatio 	= 0.5;
	
	-- globalne opcje skrzyni biegów (confix.xml)
	self.gearboxOptionsGlobal = nil;
	self:setGearboxOptionsGlobal();
	
	-- ustawianie opcji skrzyni biegów
	self:setGearboxOptions();
end;

--[[ 
	Wczytywanie specjalizacji
	@view instancja widoku
--]]
function _:loadSpec(view)
	-- add specializations
	for _, v in pairs(VehicleTypeUtil.vehicleTypes) do  
		if v ~= nil then
			for i = 1, table.maxn(v.specializations) do
				local vs = v.specializations[i];
				if vs ~= nil and vs == SpecializationUtil.getSpecialization("steerable") then
					--[[ Dodanie nowych specjalizacji --]]
					if not SpecializationUtil.hasSpecialization(gearboxSpecialization, v.specializations) then -- Specjalizacja skrzyni biegów
						local spec = SpecializationUtil.getSpecialization("gearboxSpecialization");
						table.insert(v.specializations, spec);
					end;	

					--Przekazanie referencji widoku do Steerable.Gauges_View_gearbox
					vs.Gauges_View_gearbox = view;
					--Przekazanie referencji modelu do Steerable.Gauges_Model_gearbox
					vs.Gauges_Model_gearbox = self;
					--Przekazanie referencji eventów do Steerable.Gauges_events
					vs.Gauges_events = Mods:getRegistry(self.ModelPrefix, 'events');
				end;
			end;
		end;
	end;
end;

--[[ 
	walidacja opcji
	@optionsReference referencja do obiektu opcji
--]]
function _:gearboxOptionsValidator(optionsReference)
	if optionsReference ~= nil then
		if optionsReference.gearboxMode ~= nil then
			if type(optionsReference.gearboxMode) ~= 'string' then optionsReference.gearboxMode = 'manual' end;
			if optionsReference.gearboxMode ~= 'manual' and optionsReference.gearboxMode ~= 'auto' then optionsReference.gearboxMode = 'manual' end;
		end;
		if optionsReference.maxGear ~= nil then
			if type(optionsReference.maxGear) ~= 'number' then optionsReference.maxGear = 4 end;
			if optionsReference.maxGear>9 then optionsReference.maxGear = 9 
			elseif optionsReference.maxGear<1 then optionsReference.maxGear = 1 end;
		end;
		if optionsReference.gearboxFinalRatio ~= nil then
			if type(optionsReference.gearboxFinalRatio) ~= 'number' then optionsReference.gearboxFinalRatio = 0.5 end;
			if optionsReference.gearboxFinalRatio>1 then optionsReference.gearboxFinalRatio = 1 
			elseif optionsReference.gearboxFinalRatio<0 then optionsReference.gearboxFinalRatio = 0 end;		
		end;	
	end;
end;

-- ustawia opcje skrzyni biegów
function _:setGearboxOptions()
	table.merge(self.gearboxOptions, self.gearboxOptionsGlobal);
end;

-- zwraca opcje skrzyni biegów
function _:getGearboxOptions()
	return self.gearboxOptions;
end;

-- ustawia globalne opcje skrzyni biegów
function _:setGearboxOptionsGlobal()
	if self.gearboxOptionsGlobal == nil then
		self.gearboxOptionsGlobal = {}
		self.gearboxOptionsGlobal.gearboxMode		= Utils.getNoNil(self.config:getValue('config.gearboxMode', 'string'), 'manual');
		self.gearboxOptionsGlobal.maxGear			= Utils.getNoNil(self.config:getValue('config.maxGear', 'integer'), 4);
		self.gearboxOptionsGlobal.gearboxFinalRatio	= self:calculateFinalRatio(Utils.getNoNil(self.config:getValue('config.gearboxFinalRatio', 'float'), 0.5));
		self:gearboxOptionsValidator(self.gearboxOptionsGlobal);	
	end;
end;

-- oblicza final ratio
function _:calculateFinalRatio(ratio)
	return 0.5+((ratio-0.5)*0.4);
end;