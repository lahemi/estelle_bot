#!/usr/bin/env lua5.1
-- A much simple barebones IRC bot in Lua, its very simplicity
-- being its main virtue. Peruse and extend at your leisure.
-- No warranty. No copyright, do as you wish and be happy.

-- Our "environment".
local socket = require("socket")
local http   = require("socket.http")
local table  = { concat = table.concat }
local string = { sub    = string.sub,
                 gsub   = string.gsub,
                 find   = string.find,
                 lower  = string.lower,
                 match  = string.match,
                 gmatch = string.gmatch }
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
    -- For logging.
    print(content)
end

-- A little trick for creating strings. var="stuff\ more stuff" C-stylish
-- breaking of long strings doesn't work in Lua. One option would've been
-- to use concatenation (..). That, however, is really inefficient, since
-- each concatenation call creates a new string and allocates its memory
-- and some such. This table.concat{} method is a nice way around it.
local awkhelp = table.concat{"man awk; ","man gawk; ",
                             "http://awk.freeshell.org/; ","http://awk.info; ",
                             "http://www.gnu.org/software/gawk/manual/"}
-- We have our custom "manpage", with shorter entries and less dribble.
local awkdocs = "estelledocs_awk_funcs.txt"
local awkpicker = function(name)
    local name = string.lower(name)
    local fh = io.open(awkdocs)
    local rd = fh:read('*a')
    fh:close()
    for line in rd:gmatch("[^\n]+") do
        if line:match("^"..name) then
            return line
        end
    end
end

local bashhelp = table.concat{"man bash; ",
                              "http://wiki.bash-hackers.org/start; ",
                              "http://mywiki.wooledge.org/BashGuide"}

local process = function(s, channel, lnick, line)
    if line:find("^!exit") and lnick == overlord then os.exit() end
    if line:find("^!help") then
        if line:match("^!help awk$") then
            msg(s, channel, lnick .. ': ' .. awkhelp)
        elseif line:match("^!help awk.+$") then
            local pat = line:gsub("^!help awk ","")
            local helpfun = awkpicker(pat)
            msg(s, channel, lnick .. ': ' .. helpfun)
        elseif line:match("^!help bash$") then
            msg(s, channel, lnick .. ': ' .. bashhelp)
        else
            msg(s, channel, lnick .. ': Have you tried to RTFM? :)')
        end
    end
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
    if line:find("^!fortune") then
        local fh = io.popen("./fortunes_alone.awk")
        if not fh then
            msg(s, channel, "Sadness happened.")
        else
            local stuff = fh:read('*a')
            fh:close()
            msg(s, channel, stuff)
        end
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
