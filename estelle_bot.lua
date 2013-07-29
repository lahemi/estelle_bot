#!/usr/bin/env lua5.1
-- A much simple barebones IRC bot in Lua, its very simplicity
-- being its main virtue. Peruse and extend at your leisure.

-- Our "environment".
local socket = require("socket")
local http   = require("socket.http")
local string = { sub   = string.sub,
                 gsub  = string.gsub,
                 find  = string.find,
                 match = string.match }
local print = print

-- Configuration. Fill in as your heart desires.
local overlord = "" -- "superuser", you.
local serv = ""
local nick = ""
local channel = ""
local carfeed = "\r\n\r\n"
local line = nil 
-- Connect
local s = socket.tcp()
s:connect(socket.dns.toip(serv), 6667)

-- Initialization
s:send("USER " .. nick .. "  " .. nick .. " " .. nick .. " :" .. nick .. carfeed)
s:send("NICK " .. nick .. carfeed)
s:send("JOIN " .. channel .. carfeed)

local msg = function(s, channel, content)
    s:send("PRIVMSG " .. channel .. " :" .. content .. carfeed)
end

local process = function(s, channel, lnick, line)
    if line:find("^!exit") and lnick == overlord then os.exit() end
    if line:find("^https?://") then
        local page = ""
        if line:find("%s") then
            line = line:match(".-%s"):gsub("%s","")
            page = http.request(line)
        else
            page = http.request(line)
        end
        if page == nil then
            msg(s, channel, "Something might've gone awry.")
        else
            local step = page:match("<title>%w.-</title>")
                             :gsub("<(.-)>", "")
            msg(s, channel, step)
        end
    end
    if line:find("^!tinify") then
        local tinyurl = ""
        local tinyarg = line:gsub("^!tinify ", "")
        local tinyurl = http.request("http://tinyurl.com/api-create.php?url=" .. tinyarg)
        if tinyurl == nil then
            msg(s, channel, "Something might've gone terribly wrong.")
        else
            msg(s, channel, tinyurl)
        end
    end
    if line:find("^!api") then
        local apibase = "http://www.lua.org/manual/5.1/manual.html#pdf-"
        local apilink = apibase .. line:gsub("^!api ", "")
        msg(s, channel, apilink)
    end
end

-- Parse input and handle ping.
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
            if line then
                process(s, channel, lnick, line)
            end
        end
    end

    print(receive)
end
