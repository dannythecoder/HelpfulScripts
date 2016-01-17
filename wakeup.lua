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

-- Get the MAC Address
if arg[1] ~= nil then 
    mac = arg[1]
else
    mac = "20:11:22:33:44:55"
end

--[[
	Generate the Wake on LAN Magic Packet.
	
	Format:
	    Packet content must contain 6 bytes of 0xFF followed by
	    16 copies of the 48-bit target MAC address.
	  
	Reference:
	    https://en.m.wikipedia.org/wiki/Wake-on-LAN
	    https://gist.github.com/dolzenko/4125565
	 
  ]]
function genPacket()
    local packet = '\50'
    
    packet = packet .. '\76'
    packet = packet .. '\79'
    
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
content = genPacket()
sendPacket(content)

