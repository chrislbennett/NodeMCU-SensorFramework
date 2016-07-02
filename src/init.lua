print "Checking Wifi"
if wifi.sta.status() ~= 5 then 
    print "Wifi not ready"
    tmr.alarm(6, 10000,0, function(d) dofile('init.lua') end) 
    return 
end
if wifi.sta.status() == 5 then 
    print "Starting up"
    dofile('ReaderSettings.lua')
    dofile('ReaderProcess.lua') 
    return 
end

