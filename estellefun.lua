#!/usr/bin/env lua5.1
-- A much simple IRC bot in Lua, its very simplicity being
-- its main virtue. Peruse and extend at your leisure.
-- See notice_of_goodwill_NOG.txt for exact wording of the blessings.

-- Our "environment".
local socket = require'socket'
local http   = require'socket.http'
local https  = require'ssl.https'
local tc     = table.concat -- Because we don't like ..
local string = { sub    = string.sub,
                 gsub   = string.gsub,
                 find   = string.find,
                 lower  = string.lower,
                 upper  = string.upper,
                 match  = string.match,
                 gmatch = string.gmatch }
local math   = { random = math.random }

local lapi     = require'lapi'
local light    = require'lightbulbs'
local awkfuncs = require'awkfuncs'
local religion = require'religion'
local epigrams = require'epigrams'

estellefun = {}

local overlord = ''
local channel  = ''
local CRLF     = '\r\n\r\n'
local line     = nil 
local silence  = false
local VERSION  = '0.0.6'

-- Doc strings.
local tinifyhelp  = '!tinify <url> | Print tinyurl.'
local apihelp     = '!api <func_name> | Link to corresponding Lua reference docs.'
local fortunehelp = '!fortune | Spout a short wisdom. Limited supply for the time being.'
local awkhelp     = tc{'man awk; ','man gawk; ','http://awk.freeshell.org/; ',
                       'http://awk.info; ','http://www.gnu.org/software/gawk/manual/'}
local bashhelp    = tc{'man bash; ','http://wiki.bash-hackers.org/start; ',
                       'http://mywiki.wooledge.org/BashGuide'}
local estellehelp = tc{'List of functions: ','!help, !tinify, !api, !fortune',
                       ' | See !help <func_name> for more.'}

-- For matching a url; we don't want to waste our time with links to
-- images and such; no html, no title -> no need to check for it.
local skip = function(word)
    local tl  = word:lower()
    local ret = ''
    if tl:match'.+%.jpg$'    or
       tl:match'.+%.png$'    or
       tl:match'.+%.gif$'    or
       tl:match'.+%.pdf$'    or
       tl:match'.+%.jpeg$'   or
       tl:match'.+%.mp[34]$' or
       tl:match'.+%.og[gv]$' then return nil
    elseif word:find'https' then
         ret = https.request(word)
    else ret = http.request(word) end
    return ret
end

estellefun.httpparse = function(line)
    local ret     = nil
    local tp      = '[tT][iI][tT][lL][eE]>'
    local tinyapi = 'http://tinyurl.com/api-create.php?url='

    for word in line:gmatch'%S+' do
        if word:match'https?://[%w%p]+' then
            local page = skip(word)
            if page ~= nil then
                local title = page:match(tc{'<',tp,'(.-)','</',tp})
                if title~=nil then ret = title
                else msg'The title was a lie.' end
            end
            if #word > 80 then
                local tiny = http.request(tinyapi..word)
                if tiny~=nil then
                    if ret~='' and ret~=nil then
                         ret = tc{tiny,' -- ',ret}
                    else ret = tiny end
                end
            end

            if ret~=nil then msg(ret) end

            -- We save all the posted links, for posterity.
            local fh = io.open('linksdata.txt','a')
            if fh~=nil then
                fh:write(word..'\n')
                fh:close()
            end
        end
    end
end

-- The main juices. Maybe a bit messy like.
-- It would be "cleaner" to only test test lines here and
-- then separate the functionality in different functions.
-- However, if we do it like it is now, it avoids a lot
-- of extra function calls.
estellefun.process = function(s, channel, lnick, line)
    local line = line:gsub('^!','')
    if line:find'^exit' and lnick == overlord then os.exit() end
    if line:find'^silence' and lnick == overlord then
        local set = line:gsub('^silence ','')
        if set:match'^on$' then
            silence = true
            return
        elseif set:match'^off$' then
            silence = false
            return
        end
    end

    if line:match('^version') then msg(VERSION)

    elseif line:find'^[hH][eE][lL][pP]' then
        local line = line:lower()

        if line:match'^help$' then
            msg(estellehelp)
            return
        end

        local line = line:gsub('help%s+','')

        if     line:match'^tinify%s-$'  then msg(tinifyhelp)
        elseif line:match'^api%s-$'     then msg(apihelp)
        elseif line:match'^fortune%s-$' then msg(fortunehelp)
        elseif line:match'^awk%s-$'     then msg(lnick..': '..awkhelp)
        elseif line:match'^awk.+$' then
            local pat = line:gsub('^awk ','')
            for k,v in pairs(awkfuncs) do
                if pat==k then
                    msg(k..v)
                    return
                end
            end
            msg'No such entry.'

        elseif line:match'^bash%s-$' then
            msg(bashhelp)
        else
            msg(lnick .. ': Have you tried to RTFM? :>')
        end

    elseif line:find'^religion' then
        local ret = ''
        local pat = line:gsub('^religion ',''):upper()
        for k,v in pairs(religion) do
            if pat==k then
                ret = k..v
                break
            end
        end
        if ret=='' then return
        else msg(ret) end

    elseif line:find'^tinify' then
        local tinyurl = ''
        local tinyarg = line:gsub('^tinify ','')
        local tinyurl = http.request('http://tinyurl.com/api-create.php?url='..tinyarg)
        if tinyurl == nil then
            msg"Something might've gone terribly wrong."
        else
            msg(tinyurl)
        end
        
    -- Actually tests if the searched function exists!
    elseif line:find('^api') then
        local apimsg  = ''
        local apibase = 'http://www.lua.org/manual/5.1/manual.html#pdf-'
        local apiarg  = line:gsub('^api ','')
        -- Needed for checking that nil down there.
        local apifun = function()
                for i=1,#lapi.functions do
                    if apiarg == lapi.functions[i] then
                        return apibase .. apiarg
                    end
                end
            end
        local apimsg = apifun()
        if apimsg == nil then apimsg = 'No such entry.' end
        msg(apimsg)

    -- How many X language programmers does it take to change a lightbulb.
    elseif line:find'^lightbulb' then
        local larg = string.lower(line:gsub('^lightbulb ',''))
        local qst,ans = '',''
        local lightfun = function()
                for k,v in pairs(light) do
                    if larg == k then return v[1],v[2] end
                end
            end
        local qst,ans = lightfun()
        if qst == nil then msg'No such entry.'
        else msg(qst) msg(ans) end

    -- Alan J. Perlis' Epigrams on Programming.
    elseif line:find'^epigrams?' then
        local ret = ''
        local arg = line:gsub('^epigrams? ','')
        if arg:match'%d+' then
            ret = epigrams[tonumber(arg)] or 'Out of bounds!'
        elseif arg:match'%a+' then
            for i=1,#epigrams do
                if epigrams[i]:find(arg) then
                    if epigrams[i]==sent then
                    else ret = epigrams[i] break end
                end
            end
            sent = ret -- Flips between two different.
        end
        msg(ret)

    -- I was feeling awkward that day.
    elseif line:find'^fortune' then
        local fh = io.popen'./fortunes_alone.awk'
        if fh==nil then
            msg'Sadness happened.'
        else
            local stuff = fh:read'*a'
            fh:close()
            msg(stuff)
        end
    end
end


-- Do not use this! It's for a small trusted channel, for now!
estellefun.pseudoshell = function(s, channel, lnick, line)
    local line = line:gsub('^!>','')
    if line:find'^%s?print' and lnick==overlord then
        local ret = ''
        local arg = line:gsub('^%s?print','')
        if arg:find'|%s?awk' then
            local cmd = arg:gsub('^.+|%s?awk','')
            if cmd:find'system' or
               cmd:find'ENVIRON' then return end
            local arg = arg:gsub('%s?|.+$','')
            local fh = io.popen('echo '..arg..'|awk '..cmd)
            if fh==nil then return end
            ret = fh:read'*a'
            fh:close()
        elseif arg:find'|%s?sed' then
            local cmd = arg:gsub('^.+|%s?sed','')
            local arg = arg:gsub('%s?|.+$','')
            local fh = io.popen('echo '..arg..'|sed '..cmd)
            if fh==nil then return end
            ret = fh:read'*a'
            fh:close()
        end
        if ret then msg(ret) end
    end
end


local rtest = function(str, testpat, message, freq)
    local freq = freq or 64 -- One eight of 512.
    local ret = ''
    if string.find(str,testpat) then
        if math.random(512) <= freq then    -- Adjust to your needs. Arbitrary value.
            ret = message
        else ret = 'skip' end
    else ret = 'skip' end
    if ret == 'skip' then else msg(ret) end
end

-- So AI, right, sure. Add a lot of stuff.
-- Semi-dynamic sentence generation, logical structuring!
estellefun.dospeak = function(line)
    local line = line:lower()

    if line:find'linux' then
        if (line:find'gnu%+linux' or line:find'gnu/linux') == nil then
            rtest(line, 'linux', "It's GNU+Linux, you moron!")
        end
    end

    rtest(line, 'derp', 'Muffins!')
    rtest(line, 'party', "It's party time!")
    rtest(line, 'huzzah', 'The fun has been doubled!')
    rtest(line, 'good idea', 'I totally agree with you! Not.')
    rtest(line, '%s-vim%s-', "Vi is just one of emacs's major modes!")
    rtest(line, '%s-vi%+', "Vi is just one of emacs's major modes!")
    rtest(line, 'lol', 'Oh hai thur, Ceiling cat eatednings u an stuffs!')
    rtest(line, '%s-lua%s-', "I run on Lua! That's why I'm so hot I should be on fire!")

    -- 'Speak randomly', infrequently.
    rtest(line, '.+', 'I am participating!', 1)
    rtest(line, '.+', 'Someday I will be a real person, too :<', 1)
    rtest(line, '.+', 'Unacceptable!', 1)

    -- Local finnish stuff; do ignore.
    rtest(line, 'bileet', 'No. :<')
    rtest(line, 'hässäkkä', 'Aika mones hässäkkä, et selkeästikään tiedä mitä teet.')
end

return estellefun

