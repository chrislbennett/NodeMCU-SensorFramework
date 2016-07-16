Settings = {};
Settings.Version = '2.0a';

--Device Settings
Settings.DeviceName = '2ndFloorTemperature';
--Delay between readings (ms)
Settings.ReadDelay = 2000;
--Number of Readings to Average
Settings.AverageNumReadings=4;

--MQTT Server Info
Settings.MQTTServer = '192.168.1.95';
Settings.MQTTPort = 1883;
Settings.MQTTTopic = '/ReaderData';

--Sensors Enabled
Settings.EnableDS18B20=0;
Settings.EnableHCSR04=1;
Settings.EnableDistance=0;
