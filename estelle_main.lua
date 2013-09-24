#!/usr/bin/env lua5.1
-- A much simple IRC bot in Lua, its very simplicity being
-- its main virtue. Peruse and extend at your leisure.
-- See notice_of_goodwill_NOG.txt for exact wording of the blessings.

-- Our "environment".
local socket = require("socket")
local http   = require("socket.http")
local ssl    = require("ssl")   -- from LuaSec
local table  = { concat = table.concat }
local string = { sub    = string.sub,
                 gsub   = string.gsub,
                 find   = string.find,
                 lower  = string.lower,
                 upper  = string.upper,
                 match  = string.match,
                 gmatch = string.gmatch }
local math = { random = math.random }
local print = print

-- The actual functionality is in a separate file,
-- allowing us the redefine, change and extend
-- and then reload estelle on fly.
local estellefun = require("estellefun")

-- Configuration. Fill in as your heart desires.
local overlord = "" -- "superuser", you.
local serv = ""
local nick = ""
local channel = ""
local carfeed = "\r\n\r\n"
local line = nil 

-- For the ssl.
local params = { 
    mode = "client",
    protocol = "sslv3",
    cafile = "/etc/ssl/certs/ca-certificates.crt",
    verify = "peer",
    options = "all",
}
local s = socket.tcp()
-- Or just s:connect(socket.dns.toip(serv),6667)
-- if don't want to use ssl. Of course remove
-- ssl.wrap and dohandshake then too.
s:connect(socket.dns.toip(serv), 6697)
s = ssl.wrap(s,params)
s:dohandshake()

-- Initialization
s:send("USER " .. nick .. "  " .. nick .. " " .. nick .. " :" .. nick .. carfeed)
s:send("NICK " .. nick .. carfeed)
s:send("JOIN " .. channel .. carfeed)

-- Works for single channel bot. Elaborate further as necessary.
msg = function(content)
    s:send("PRIVMSG " .. channel .. " :" .. content .. carfeed)
    print(content)  -- For logging.
end

-- Parse input and handle pingpong. The main loop.
while true do
    local receive = s:receive('*l')

    -- Need to pong them to tell we're still alive.
    if receive:find("PING :") then
        s:send("PONG :" .. receive:sub((receive:find("PING :") + 6)) .. carfeed)
    else
        -- Parse
        if receive:find("PRIVMSG") then
            if receive:find(channel .. " :") then
                line = receive:sub((receive:find(channel .. " :") + (#channel) + 2))
            end
            if receive:find(":") and receive:find("!") then
                lnick = receive:sub((receive:find(":")+1),
                                    (receive:find("!")-1))
            end
            -- The actual functionality.
            if line then
                estellefun.process(s, channel, lnick, line)
                if silence == false then
                    estellefun.dospeak(line)
                end
                if line:match("^!reload$") and lnick == overlord then
                     package.loaded[ 'estellefun' ] = nil
                     estellefun = require('estellefun')
                end
            end
        end
    end

    print(receive)
end

