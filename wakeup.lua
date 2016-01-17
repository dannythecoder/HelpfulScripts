#!/usr/bin/lua
--
-- wakeup.lua
--
-- Written by Danny Caudill (DannyTheCoder).
-- January 10, 2016
--
--             Copyright Danny Caudill. 2014.
-- Distributed under the Boost Software License, Version 1.0.
--    (See accompanying file LICENSE_1_0.txt or copy at
--        http://www.boost.org/LICENSE_1_0.txt)
--
-- Send a Wake On Lan packet on this LAN segment
-- 
-- Usage:
-- lua wakeup.lua <mac address>
--
-- Example: 
-- lua wakeup.lua 20:11:22:33:44:55
-- 
-- Dependencies:
-- Lua 5.0
-- lua-socket
--

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
    macList[0] = 76
    macList[1] = 77
    macList[2] = 78
    macList[3] = 79
    macList[4] = 80
    macList[5] = 81
    
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
function sendPacket(content)
    if debug then
        print(content)
    end
    
    sock = socket.udp()
    sock:setoption('broadcast', true)
    sock:sendto(content, '239.255.255.250', 7)

end

-- Main subroutine
function main()

    -- Get the MAC Address
    if arg[1] ~= nil then 
        mac = arg[1]
    else
        mac = "20:11:22:33:44:55"
    end
    
    content = genPacket(mac)
    sendPacket(content)
    
end

main()
