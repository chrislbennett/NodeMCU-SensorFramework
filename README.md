# NodeMCU-SensorFramework
Simple Starter project for creating sensors using the NodeMCU devices.

While [NodeMCU](https://github.com/nodemcu/nodemcu-firmware) is a very good base platform for ESP8266 devices, it is a bit difficult to get started and make it reliable.  While fighting through creating IoT devices for my house, I settled on a simple code base which would support one or more of the following sensors:

1. DS18b20 Temperature Sensor
  All weather temperature sensor, perfect for monitoring freezer temperatures.
2. DHT22 Temperature and Humidity Sensor
  Very usable for tracking humidy and temperature in various parts of the house.  (Indoor only)
3. HC-SR04 Distance Sensor
  Perfect sensor for measuring water depth in a sump

The sensors are read at a regular interval, sent as a JSON object to an MQTT server which is a perfect for feeding into [NodeRed](http://nodered.org/) for further processing (to log, send to a front end UI, etc.)

