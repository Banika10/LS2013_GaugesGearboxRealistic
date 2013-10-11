-------------------------------------------------------------+
-- Copyright © 2013 Rafa³ Miko³ajun (MIKO) | rafal@mikoweb.pl
-- license: GNU General Public License version 3 or later; see LICENSE.txt
--
-- www.mikoweb.pl
-- www.swiat-ls.pl
--
-- Gauges Gearbox & Realistic
-- Gauge RPM Specialization
--
-- wysy³anie zmiennych do wyœwietlacza obrotów:
------------------------------------------------------------*/

gaugeRpm = {};

function gaugeRpm.prerequisitesPresent(specializations)
	return true;
end;

function gaugeRpm:load(xmlFile)
	self.gaugeRpm 				= {}
	self.gaugeRpm.view 			= Steerable.Gauges_View_rpm; -- referencja do widoku wyœwietlacza obrotów
	self.gaugeRpm.tipMaxWidth 	= self.gaugeRpm.view.rpmGaugeWindowTipMaxWidth;
	
	function self.gaugeRpm.rpmTipCaption(num, pos) 
		local mult = 10^(1 or 0)
		--if pos % 2 ~= 0 then
		if num<1 then
			local caption = string.sub(tostring(math.floor(num * mult + 0.5) / mult), 0, 3);
			if string.len(caption) == 1 then caption = caption..'.0' end;
			return caption;
		elseif num>=1 and num <10 then
			local caption = string.sub(tostring(math.floor(num * mult + 0.5) / mult), 0, 3);
			if string.len(caption) == 1 then caption = caption..'.0' end;
			return caption;				
		elseif num>=10 and num<100 then
			local caption = string.sub(tostring(math.floor(num * mult + 0.5) / mult), 0, 4);
			if string.len(caption) == 2 then caption = caption..'.0' end;
			return caption;
		elseif num>=100 and num<1000 then 
			local caption = string.sub(tostring(math.floor(num * mult + 0.5) / mult), 0, 5);
			if string.len(caption) == 3 then caption = caption..'.0' end;
			return caption;
		else return '' end;
		--else return '' end;
	end;
end;

function gaugeRpm:readStream(streamId, connection)
end;

function gaugeRpm:writeStream(streamId, connection)
end;

function gaugeRpm:delete()
end;

function gaugeRpm:mouseEvent(posX, posY, isDown, isUp, button)
end;

function gaugeRpm:keyEvent(unicode, sym, modifier, isDown)
end;

function gaugeRpm:update(dt)
	if self.isMotorStarted and self.isEntered then
		local mult 				= 10^(3 or 0)
		local rpmTipSegment 	= math.floor(self.motor.maxRpm[3]/9000 * mult + 0.5) / mult;
		self.gaugeRpm.view.rpmGaugeWindowC1.text	= self.gaugeRpm.rpmTipCaption(rpmTipSegment);
		self.gaugeRpm.view.rpmGaugeWindowC2.text	= '';
		self.gaugeRpm.view.rpmGaugeWindowC3.text	= self.gaugeRpm.rpmTipCaption(rpmTipSegment*3);
		self.gaugeRpm.view.rpmGaugeWindowC4.text	= '';
		self.gaugeRpm.view.rpmGaugeWindowC5.text	= self.gaugeRpm.rpmTipCaption(rpmTipSegment*5);
		self.gaugeRpm.view.rpmGaugeWindowC6.text	= '';
		self.gaugeRpm.view.rpmGaugeWindowC7.text	= self.gaugeRpm.rpmTipCaption(rpmTipSegment*7);
		self.gaugeRpm.view.rpmGaugeWindowC8.text	= '';
		self.gaugeRpm.view.rpmGaugeWindowC9.text	= self.gaugeRpm.rpmTipCaption(rpmTipSegment*9);
	
		local rpmTipPercentage 			= self.motor.lastMotorRpm*100/self.motor.maxRpm[3];
		local rpmTipWidth				= self.gaugeRpm.tipMaxWidth*rpmTipPercentage/100;
		if rpmTipWidth>self.gaugeRpm.tipMaxWidth then rpmTipWidth = self.gaugeRpm.tipMaxWidth end;
		self.gaugeRpm.view.rpmGaugeWindowTip.width 	= rpmTipWidth;
	end;
end;

function gaugeRpm:updateTick(dt)
end;

function gaugeRpm:draw()
	if self.isMotorStarted then
		self.gaugeRpm.view.rpmGaugeWindow:show(); -- poka¿ wyœwietlacz obrotów na ekranie
	else
		self.gaugeRpm.view.rpmGaugeWindow:hide(); -- ukryj
	end;
end;