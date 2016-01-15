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
lon = "-81.548"

debug = true

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

    tempMinStart = string.find(content, "Daily Minimum Temperature")
    tempMaxStart = string.find(content, "Daily Maximum Temperature")
    
    if tempMinStart == nil or tempMaxStart == nil then
        return nil
    end

    result["Lo Today   "] = string.sub(content, tempMinStart + 26, tempMinStart + 27)
    result["Lo Tomorrow"] = string.sub(content, tempMinStart + 29, tempMinStart + 30)
    result["Lo Tomorr+1"] = string.sub(content, tempMinStart + 32, tempMinStart + 33)
    result["Lo Tomorr+2"] = string.sub(content, tempMinStart + 35, tempMinStart + 36)
    
    result["Hi Today   "] = string.sub(content, tempMaxStart + 26, tempMaxStart + 27)
    result["Hi Tomorrow"] = string.sub(content, tempMaxStart + 29, tempMaxStart + 30)
    result["Hi Tomorr+1"] = string.sub(content, tempMaxStart + 32, tempMaxStart + 33)
    result["Hi Tomorr+2"] = string.sub(content, tempMaxStart + 35, tempMaxStart + 36)

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
    else
        -- Get the content from a website
        local url = "http://forecast.weather.gov/MapClick.php?lat=" .. lat .. "&lon=" .. lon .. "&unit=0&lg=english&FcstType=dwml"

        if debug then
            print(url)
        end

        local http = require'socket.http'
        body, c, l, h = http.request(url)
        content = body

    end

    return content
end


-- Main subroutine
content = getContent()
weather = parseContent(content)

-- For now, just display the content and parsed version
if debug then
    print(content)
    print("\n\n")
end

for key, value in pairs(weather) do print(key, value) end

