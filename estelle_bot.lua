#!/usr/bin/env lua5.1
-- A much simple barebones IRC bot in Lua, its very simplicity
-- being its main virtue. Peruse and extend at your leisure.
-- See UNLICENSE.txt for exact wording of the blessings.

-- Our "environment".
local socket = require("socket")
local http   = require("socket.http")
local table  = { concat = table.concat }
local string = { sub    = string.sub,
                 gsub   = string.gsub,
                 find   = string.find,
                 lower  = string.lower,
                 upper  = string.upper,
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

-- Works for single channel bot.
local msg = function(content)
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
local awkpicker = function(name)
    local name = string.lower(name)
    local fh = io.open("estelledocs_awk_funcs.txt")
    local rd = fh:read('*a')
    fh:close()
    for line in rd:gmatch("[^\n]+") do
        if line:match("^"..name) then
            return line
        end
    end
end
-- If programming languages were religions.
local relpicker = function(pat)
    local pat = string.upper(pat)
    -- C++ is so special
    if pat == "C++" then pat = "C%+%+" end
    local fh = io.open("religion.txt")
    local rd = fh:read('*a')
    fh:close()
    for line in rd:gmatch("[^\n]+") do
        if line:match("^"..pat.." ") then
            return line
        end
    end
end

local bashhelp = table.concat{"man bash; ",
                              "http://wiki.bash-hackers.org/start; ",
                              "http://mywiki.wooledge.org/BashGuide"}
local estellehelp = table.concat{"List of functions: ",
                                 "!help, !tinify, !api, !fortune",
                                 " | See !help <func_name> for more."}
local apihelp     = "!api <func_name> | Link to corresponding Lua reference docs."
local tinifyhelp  = "!tinify <url> | Print tinyurl."
local fortunehelp = "!fortune | Spout a short wisdom. Limited supply for the time being."
-- For matching a url, we don't want to waste our time with
-- links to images; no html, no title -> no need to check for it.
local skip = function(line)
    local ret = ""
    if line:match(".+%.jpg$") or
       line:match(".+%.jpeg$") or
       line:match(".+%.png$") or
       line:match(".+%.gif$") then ret = "skip"
    else ret = http.request(line) end
    return ret
end

local process = function(s, channel, lnick, line)
    if line:find("^!exit") and lnick == overlord then os.exit() end
    if line:find("^!help") then
        if line:match("^!help$") then
            msg(estellehelp)
        elseif line:match("^!help !?tinify$") then
            msg(tinifyhelp)
        elseif line:match("^!help !?api$") then
            msg(apihelp)
        elseif line:match("^!help !?fortune$") then
            msg(fortunehelp)
        elseif line:match("^!help awk$") then
            msg(lnick..': '..awkhelp)
        elseif line:match("^!help awk.+$") then
            local pat = line:gsub("^!help awk ","")
            local helpfun = awkpicker(pat)
            if helpfun == nil then
                msg("No such entry.")
            else
                msg(lnick .. ': ' .. helpfun)
            end
        elseif line:match("^!help bash$") then
            msg(lnick .. ': ' .. bashhelp)
        else
            msg(lnick .. ': Have you tried to RTFM? :)')
        end
    elseif line:find("^!religion") then
        local pat = line:gsub("^!religion ","")
        local rel = relpicker(pat)
        if rel == nil then
            msg("No such entry.")
        else
            msg(rel)
        end
    elseif line:find("^https?://") then
        local page = ""
        -- In case any text follows the url.
        if line:find("%s") then
            line = line:match(".-%s"):gsub("%s","")
            page = skip(line)
        else
            page = skip(line)
        end
        if page == "skip" then
        elseif page == nil then
            msg("Something might've gone awry.")
        else
            local page = page:match("<title>%w.-</title>") or
                         page:match("<TITLE>%w.-</TITLE>")
            -- Some necessary error handling.
            if page == nil then
                page = "Something funny up with the title."
            else
                page = page:gsub("<(.-)>", "")
            end
            msg(page)
        end
        if #line > 80 then
            local tin = ""
            local tin = http.request("http://tinyurl.com/api-create.php?url=" .. line)
            msg(tin)
        end
    elseif line:find("^!tinify") then
        local tinyurl = ""
        local tinyarg = line:gsub("^!tinify ", "")
        local tinyurl = http.request("http://tinyurl.com/api-create.php?url=" .. tinyarg)
        if tinyurl == nil then
            msg("Something might've gone terribly wrong.")
        else
            msg(tinyurl)
        end
    elseif line:find("^!api") then
        local apibase = "http://www.lua.org/manual/5.1/manual.html#pdf-"
        local apilink = apibase .. line:gsub("^!api ", "")
        msg(apilink)
    elseif line:find("^!fortune") then
        local fh = io.popen("./fortunes_alone.awk")
        if not fh then
            msg("Sadness happened.")
        else
            local stuff = fh:read('*a')
            fh:close()
            msg(stuff)
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
