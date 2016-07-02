# NodeMCU Sensor Framework
Simple Starter project for creating sensors using the NodeMCU devices.

While [NodeMCU](https://github.com/nodemcu/nodemcu-firmware) is a very good base platform for ESP8266 devices, it is a bit difficult to get started and make it reliable.  While fighting through creating IoT devices for my house, I settled on a simple code base which would support one or more of the following sensors:

1. DS18b20 Temperature Sensor
  All weather temperature sensor, perfect for monitoring freezer temperatures.
2. DHT22 Temperature and Humidity Sensor
  Very usable for tracking humidy and temperature in various parts of the house.  (Indoor only)
3. HC-SR04 Distance Sensor
  Perfect sensor for measuring water depth in a sump

The sensors are read at a regular interval, sent as a JSON object to an MQTT server which is a perfect for feeding into [NodeRed](http://nodered.org/) for further processing (to log, send to a front end UI, etc.)

## Theory of Operation
The framework performs the following simple process to provide to feed the sensor data to the server.
1. Upon startup, wait for the WIFI module to connect to the network.  It does this by checking every 10 seconds for connectivity.
2. Attempt to connect to MQTT, if it fails wait 10 seconds and try again.
3. Begin checking the sensors and sending data to the MQTT server.
4. If the connection to MQTT fails, it will automatically retry the connections.
5. If WIFI fails, it will go back to waiting until it comes back online.

## Development Tools
In case your looking for dev tools to use for modifying the LUA code, there are several tools out there.  Here are a couple of  I've used previously.

* [ESPlorer](http://esp8266.ru/esplorer/)
* [LUA Loader](http://benlo.com/esp8266/)

## Installing
1. Make sure your NodeMCU/ESP8266 device is already running the NodeMCU firmware.
2. Make sure your module is configured for your wifi network.  If not, use the wifi.sta.config("SSID","password") command to configure for your network.
3. Uploading the LUA files for the drivers, ds18b20.lua and hcsr04.lua.
4. Upload the ReaderProcess.lua file
5. Modify and upload the the ReaderSettings.lua file to suit your needs.  Be sure to specify the device name, MQTT server and the sensors you plan to connect.
6. Once you're ready, upload the init.lua which will immediately launch the process.
