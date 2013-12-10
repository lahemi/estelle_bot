#!/usr/bin/env lua5.1
-- A much simple IRC bot in Lua, its very simplicity being
-- its main virtue. Peruse and extend at your leisure.
-- See notice_of_goodwill_NOG.txt for exact wording of the blessings.

-- Our "environment".
local socket = require'socket'
local http   = require'socket.http'
local ssl    = require'ssl'   -- from LuaSec
local tc     = table.concat   -- Because we don't like ..
local ipairs = ipairs
local print  = print
local math   = { random = math.random }
local string = { sub    = string.sub,
                 gsub   = string.gsub,
                 find   = string.find,
                 lower  = string.lower,
                 upper  = string.upper,
                 match  = string.match,
                 gmatch = string.gmatch }

local ctbl = require'conftbl'

-- The actual functionality is in a separate file,
-- allowing us the redefine, change and extend
-- and then reload estelle on fly.
local estellefun = require'estellefun'

-- From separate conf file.
local overlord = ctbl.overlord
local nick     = ctbl.nick
local serv     = ctbl.serv
local channels = ctbl.channels -- a table!
local channel  = ''
local VERSION  = ctbl.version

local CRLF     = '\r\n\r\n'
local line     = nil 

-- For the ssl.
local params = { 
    mode = 'client',
    protocol = 'tlsv1',
    cafile = '/etc/ssl/certs/ca-certificates.crt',
    verify = 'peer',
    options = 'all',
}
local s = socket.tcp()
-- Or just s:connect(socket.dns.toip(serv),6667)
-- if don't want to use ssl. Of course remove
-- ssl.wrap and dohandshake then too.
s:connect(socket.dns.toip(serv), 6697)
s = ssl.wrap(s,params)
s:dohandshake()

-- Initialization
s:send(tc{'USER ',nick,'  ',nick,' ',nick,' :',nick,CRLF})
s:send(tc{'NICK ',nick,CRLF})

for _,ch in ipairs(channels) do
    s:send(tc{'JOIN ',ch,CRLF})
end

-- "Print"
wflush = function(str)
    io.write(str..'\n')
    io.stdout:flush()
end

msg = function(content,channel)
    s:send(tc{'PRIVMSG ',channel,' :',content,CRLF})
    wflush(content)  -- For logging.
end

-- Parse input and handle pingpong. The main loop.
while true do
    local rec = s:receive('*l')

    -- Need to pong them to tell we're still alive.
    if rec:find'PING :' then
        s:send('PONG :'..rec:sub((rec:find('PING :') + 6))..CRLF)
    else
        -- Parse
        if rec:find'PRIVMSG' then
            channel = rec:match'PRIVMSG (.+) :'
            if rec:find(channel..' :') then
                line = rec:sub((rec:find(channel..' :') + (#channel) + 2))
            end
            if rec:find':' and rec:find'!' then
                lnick = rec:sub((rec:find':'+1), (rec:find'!'-1))
            end
            -- The actual functionality.
            if line~=nil then
                if line:find'^!>' then
                    estellefun.pseudoshell(s, channel, lnick, line)
                elseif line:find'^!' then
                    estellefun.process(s, channel, lnick, line)
                end
                if line:find'http' then estellefun.httpparse(line,channel) end
                if silence==false  then estellefun.dospeak(line,channel)   end
                if line:match'^!reload$' and lnick == overlord then
                     package.loaded['estellefun'] = nil
                     estellefun = require'estellefun'
                end
            end
        end
    end

    -- This way can see everything in the console. Mixes up the channels,
    -- though you can do some parsing there if you wish.
    wflush(rec)
end

