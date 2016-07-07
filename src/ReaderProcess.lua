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

-- init mqtt client with keepalive timer 120sec
mqttconnected = 0

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
        print("Sending New Readings")
        ctemp=0
        dist=0
        temp=0
        humi=0

        --make sure the DS18B20 is enabled
        if Settings.EnableDS18B20==1 then        
            ctemp = t.read()
            if ctemp ~= nil then
                print("Temp1:"..ctemp)
            end
        end

        --make sure the distance sensor is enabled
        if Settings.EnableDistance==1 then
            dist = device.measure_avg()*100

            if dist ~= nil then
                print("Dist:"..dist)    
            end
        end

        --make sure the temp/humi sensor is enabled
        if Settings.EnableHCSR04==1 then
            --read the temp/humidity sensor
            status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
            if status == dht.OK then
                print("Temp2:"..temp)
                print("Humi2:"..humi)
            end
        end

        msg={}
        msg.temp1=ctemp
        msg.depth1=dist
        msg.temp2=temp
        msg.humi2=humi
        msg.DeviceName=Settings.DeviceName
        msg.Version=Settings.Version

        m:publish(Settings.MQTTTopic,cjson.encode(msg),0,0)

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
