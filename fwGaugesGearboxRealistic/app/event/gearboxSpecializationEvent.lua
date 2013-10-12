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

gearboxSpecializationEvent = {};
gearboxSpecializationEvent_mt = Class(gearboxSpecializationEvent, Event);

InitEventClass(gearboxSpecializationEvent, "gearboxSpecializationEvent");

function gearboxSpecializationEvent:emptyNew()
    local self = Event:new(gearboxSpecializationEvent_mt);
    self.className="gearboxSpecializationEvent";
    return self;
end;

function gearboxSpecializationEvent:new(vehicle)
    local self = gearboxSpecializationEvent:emptyNew()
    self.vehicle = vehicle;
    return self;
end;

function gearboxSpecializationEvent:readStream(streamId, connection)
    local id = streamReadInt32(streamId);
    self.vehicle = networkGetObject(id);
    self:run(connection);
end;

function gearboxSpecializationEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
end;

function gearboxSpecializationEvent:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(gearboxSpecializationEvent:new(self.vehicle), nil, connection, self.object);
	end;
	self.vehicle:gearboxMultiplayerSynchro(vehicle);
end;

function gearboxSpecializationEvent.sendEvent(vehicle, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(gearboxSpecializationEvent:new(vehicle), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(gearboxSpecializationEvent:new(vehicle));
		end;
	end;
end;
