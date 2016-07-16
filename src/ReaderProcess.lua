--setup the temp sensor
t=require("ds18b20")
t.setup(5)

--setup the distance sensor
dofile("hcsr04.lua")
device = hcsr04.init()

--setup the LED pin
ledpin=0
gpio.mode(ledpin,gpio.OUTPUT)
led_state=0

--setup the averaging objects used later
temp1Readings = {};
distReadings = {};
temp2Readings = {};
humi2Readings = {};
readingsCount=0;

for i=0,Settings.AverageNumReadings do
    temp1Readings[i] = 0;
    distReadings[i] = 0;
    temp2Readings[i] = 0;
    humi2Readings[i] = 0;
end

-- init mqtt client with keepalive timer 120sec
mqttconnected = 0

--used to average together set of values and return an averaged value
function average_readings(obj, newValue)   
    --move the values around to make it work
    for i=Settings.AverageNumReadings,1,-1 do
        obj[i-1] = obj[i];
    end
    --insert the new reading
    obj[Settings.AverageNumReadings] = newValue;

    --average the values
    avg = 0
    for i=0,Settings.AverageNumReadings,1 do
        avg = avg + obj[i];
    end

    return avg/Settings.AverageNumReadings;
end

--Used to establish the mqtt connecttion
function connect_mqtt()
    print("calling connect")
    m:connect(Settings.MQTTServer, Settings.MQTTPort, 0)

    --start up a timer to follow up and check the connection to make sure it starts up
    tmr.alarm(1,20000,0,function()
        if mqttconnected == 0 then
            --not connected, try again
            m:close()
            connect_mqtt()
        end
    end)
end
m = mqtt.Client(wifi.sta.getmac(), 5)

-- setup Last Will and Testament (optional)
-- Broker will publish a message with:
-- qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)

m:on("connect", function(con) 
        print ("connected") 
        mqttconnected=1
    end)
m:on("offline", function(con) 
        print ("offline") 
        mqttconnected = 0
        m:close();
        
        --reconnect the mqtt
        tmr.alarm(1,10000,0,function() 
            connect_mqtt()
        end)
    end)

-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
end)

--fire the timer to send the data points if mqtt is available
tmr.alarm(0,Settings.ReadDelay,1,function()

    if mqttconnected == 1 then
        print("-----------------------")
        print("Reading Sensors")
        ctemp=0
        dist=0
        temp=0
        humi=0

        --make sure the DS18B20 is enabled
        if Settings.EnableDS18B20==1 then        
            ctemp = t.read()
            if ctemp ~= nil then
               ctemp=average_readings(temp1Readings,ctemp);
               
               print("Temp1:"..ctemp)
            end
        end

        --make sure the distance sensor is enabled
        if Settings.EnableDistance==1 then
            dist = device.measure_avg()*100

            if dist ~= nil then
                dist=average_readings(distReadings,dist);
                print("Dist:"..dist)    
            end
        end

        --make sure the temp/humi sensor is enabled
        if Settings.EnableHCSR04==1 then
            --read the temp/humidity sensor
            status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
            if status == dht.OK then
                temp=average_readings(temp2Readings,temp);
                humi=average_readings(humi2Readings,humi);

                print("Temp2:"..temp)
                print("Humi2:"..humi)
            end
        end
       
        --figure out if we have enough sensor data to work with
        if readingsCount<=Settings.MinimumNumReadings then
            readingsCount = readingsCount+1;
            print("Waiting for More Readings")
        else
            print("Sending Readings")
            msg={}
            msg.temp1=ctemp
            msg.depth1=dist
            msg.temp2=temp
            msg.humi2=humi
            msg.DeviceName=Settings.DeviceName
            msg.Version=Settings.Version

            m:publish(Settings.MQTTTopic,cjson.encode(msg),0,0)
        end


        --free up memory
        ctemp = nil
        dist = nil
        status=nil
        temp=nil
        humi=nil
        temp_decimal=nil
        humi_decimal=nil

        --blink the LED
        if led_state == 0 then
            gpio.write(ledpin,gpio.HIGH)
            led_state=1
        else
            gpio.write(ledpin,gpio.LOW)
            led_state=0
        end
    else
        print("Not Connected")
    end        
end)

--start the connection
connect_mqtt()
