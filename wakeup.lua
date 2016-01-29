#!/usr/bin/lua
--[[
 wakeup.lua

 Written by Danny Caudill (DannyTheCoder).
 January 10, 2016

             Copyright Danny Caudill. 2014.
 Distributed under the Boost Software License, Version 1.0.
    (See accompanying file LICENSE_1_0.txt or copy at
        http://www.boost.org/LICENSE_1_0.txt)

 Send a Wake On Lan packet on this LAN segment

 Usage:
 lua wakeup.lua <mac address>

 Example:
 lua wakeup.lua 20:11:22:33:44:55

 Dependencies:
 Lua 5.0
 lua-socket

]]

require "socket"

debug = true

--[[
	Generate the Wake on LAN Magic Packet.
	
	Format:
	    Packet content must contain 6 bytes of 0xFF followed by
	    16 copies of the 48-bit target MAC address.
	  
	Reference:
	    https://en.m.wikipedia.org/wiki/Wake-on-LAN
	    https://gist.github.com/dolzenko/4125565
	 
]]
function genPacket(mac)
    local packet = '\255\255\255\255\255\255'
    
    -- convert mac to a 6 numbers
    macList = {}
    macList[0] = tonumber(string.sub(mac, 0, 2), 16)
    macList[1] = tonumber(string.sub(mac, 4, 5), 16)
    macList[2] = tonumber(string.sub(mac, 7, 8), 16)
    macList[3] = tonumber(string.sub(mac, 10, 11), 16)
    macList[4] = tonumber(string.sub(mac, 13, 14), 16)
    macList[5] = tonumber(string.sub(mac, 16, 17), 16)
    
    if debug then
        print('MAC Address bytes:')
        for k, v in pairs(macList) do
            print(k, v)
        end
    end

    -- add bytes 16 times
    local i = 0
    while i < 16 do
    	local k = 0
    	while k < 6 do
            packet = packet .. string.char(macList[k])
            k = k + 1
        end
        i = i + 1
    end
    
    return packet
end

--[[
    Send the packet.
    
	Convention uses UDP port 7, but any layer 3/4 combination should work.
	Could use broadcast Address 239.255.255.250 (the address used for uPnP)
	  
	Reference:
	    http://w3.impa.br/~diego/software/luasocket/udp.html
	  
]]
function sendPacket(content, ip)
    if debug then
        -- print(content)
        local i = 0
        while i < content:len() do
            print(string.byte(string.sub(content, i, i)))
            i = i + 1
        end
    end

    sock = socket.udp()
    if ip == nil then
        bcastIP = '239.255.255.250'
        print('Sending broadcast to:', bcastIP)
        sock:setoption('broadcast', true)
        sock:sendto(content, bcastIP, 7)
    else
        -- Send only to the target IP
        print('Sending to:', ip)
        sock:sendto(content, ip, 7)
    end
end

-- Main subroutine
function main()

    -- Get the MAC Address
    if arg[1] ~= nil then 
        mac = arg[1]
    else
        mac = '20:31:32:33:34:35'
    end

    -- Get the (optional) destination IP
    if arg[2] ~= nil then
        ip = arg[2]
    end

    content = genPacket(mac)
    sendPacket(content, ip)

end

main()
