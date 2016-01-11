#!/usr/bin/lua
--
-- get_weather.lua
--
-- Written by Danny Caudill (DannyTheCoder).
-- January 10, 2016
--
--             Copyright Danny Caudill. 2014.
-- Distributed under the Boost Software License, Version 1.0.
--    (See accompanying file LICENSE_1_0.txt or copy at
--        http://www.boost.org/LICENSE_1_0.txt)
--
-- Get the current weather forecast
-- http://forecast.weather.gov/MapClick.php?lat=28.3714&lon=-81.548&unit=0&lg=english&FcstType=dwml
--
-- Update the Latitude and Longitude.  The default values are for Disney World
-- in Florida.

lat = "28.3714"
long = "-81.548"

-- During testing, load from sample_weather.dat (instead of getting
-- the latest version from the website).
if arg[1] == "test" then 
    testMode = true
else
    testMode = false
end

-- Determine which test to run
whichTest = 0
if arg[2] ~= nil then
    whichTest = tonumber(arg[2])
end

--[[
    Parse the returned content.
  ]]
function parseContent(content)
    result = {}
    
    result["Today"] = 76
    result["Tomorrow"] = 72
    result["Today + 2"] = 71
    
    return result
end

--[[
    Retrieve the content.
  ]]
function getContent()
    if testMode then
        print("Selected test: " .. whichTest)
        local file = assert(io.open("sample_weather.dat", "r"))
        content = file:read()
        file:close()
    end
    
    return content
end


-- Main subroutine
content = getContent()
weather = parseContent(content)

-- For now, just display the content
print(content)

