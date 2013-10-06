#!/usr/bin/env lua5.1
-- A much simple IRC bot in Lua, its very simplicity being
-- its main virtue. Peruse and extend at your leisure.
-- See notice_of_goodwill_NOG.txt for exact wording of the blessings.

-- TODO meme generator. logical trees, and with a time limit:
-- allow a new meme to be generated once in a hour or so.


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
local math = { random = math.random }
local print = print

local lapi = require("lapi")

estellefun = {}

local overlord = ""
local channel = ""
local carfeed = "\r\n\r\n"
local line = nil 
local silence = false

-- A little trick for creating strings. var="stuff\ more stuff" C-stylish
-- breaking of long strings doesn't work in Lua. One option would've been
-- to use concatenation (..). That, however, is really inefficient, since
-- each concatenation call creates a new string and allocates its memory
-- and some such. This table.concat{} method is a nice way around it.
local awkhelp = table.concat{"man awk; ","man gawk; ",
                             "http://awk.freeshell.org/; ","http://awk.info; ",
                             "http://www.gnu.org/software/gawk/manual/"}

-- A sort of generic file reading helper
-- function, with some "error handling".
local filereadall = function(file)
    local ret = ""
    if not file then -- Magicks of empty if body.
    else
        local fh = io.open(file)
        if not fh then
            ret = "File handle not handled!"
        else
            ret = fh:read('*a')
            fh:close()
        end
        return ret
    end 
end

-- We have our custom "manpage", with shorter entries and less dribble.
local awkpicker = function(name)
    local name = string.lower(name)
    local rd = filereadall("estelledocs_awk_funcs.txt")
    for line in rd:gmatch("[^\n]+") do
        if line:match("^"..name) then
            return line
        end
    end
end
-- If programming languages were religions.
local relpicker = function(pat)
    local pat = string.upper(pat)
    -- C++ is so special.
    if pat == "C++" then pat = "C%+%+" end
    local rd = filereadall("religion.txt")
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
-- For matching a url; we don't want to waste our time with links to
-- images and such; no html, no title -> no need to check for it.
local skip = function(line)
    local line = string.lower(line)
    local ret = ""
    if line:match(".+%.jpg$")    or
       line:match(".+%.png$")    or
       line:match(".+%.gif$")    or
       line:match(".+%.pdf$")    or
       line:match(".+%.jpeg$")   or
       line:match(".+%.mp[34]$") or
       line:match(".+%.og[gv]$") then ret = "skip"
    else ret = http.request(line) end
    return ret
end

local urlsaver = function(line)
    local urls = {}
    for word in line:gmatch("%S+") do
        if word:match("https?://[%w%p]+") then
            urls[#urls+1] = word
        end
    end
    local fh = io.open("linksdata.txt","a")
    if fh then
        for i=1,#urls do
            fh:write(urls[i].."\n")
        end
    end
    fh:close()
end

-- The main juices. Maybe a bit messy like.
estellefun.process = function(s, channel, lnick, line)
    if line:find("^!exit") and lnick == overlord then os.exit() end
    if line:find("^!silence") and lnick == overlod then
        local set = line:gsub("^!silence ","")
        if set:match("^on$") then
            silence = true
            return
        elseif set:match("^off$") then
            silence = false
            return
        end
    end

    if line:find("^![hH][eE][lL][pP]") then
        local line = string.lower(line)

        if line:match("^!help$") then
            msg(estellehelp)
            return
        end

        local line = line:gsub("!help%s+","")

        if     line:match("^!?tinify%s-$")  then msg(tinifyhelp)
        elseif line:match("^!?api%s-$")     then msg(apihelp)
        elseif line:match("^!?fortune%s-$") then msg(fortunehelp)
        elseif line:match("^awk%s-$")       then msg(lnick..': '..awkhelp)
        elseif line:match("^awk.+$") then
            local pat = line:gsub("^awk ","")
            local helpfun = awkpicker(pat)
            if helpfun == nil then
                msg("No such entry.")
            else
                msg(helpfun)
            end
        elseif line:match("^bash%s-$") then
            msg(bashhelp)
        else
            msg(lnick .. ': Have you tried to RTFM? :>')
        end

    elseif line:find("^!religion") then
        local pat = line:gsub("^!religion ","")
        local rel = relpicker(pat)
        if rel == nil then
            msg("No such entry.")
        else
            msg(rel)
        end

    -- Deliberately ignoring https.
    elseif line:find("http://") then
        urlsaver(line)
        local page = ""
        local url  = ""

        if line:find("http://[%w%p]+%s") == nil then
            local s,e = line:find("http://[%w%p]+")
            url = line:sub(s,e)
            page = skip(url)
        else
            local s,e = line:find("http://[%w%p]+%s")
            url = line:sub(s,(e-1))
            page = skip(url)
        end

        if page == "skip" then  -- Empty if body !
        elseif page == nil then
            msg("Something might've gone awry.")
        else
            local title = page:match("<[tT][iI][tT][lL][eE]>(.-)</[tT][iI][tT][lL][eE]>")
            -- Some necessary error handling.
            if title == nil then title = "The title was a lie."
            else title = title:gsub("<(.-)>", "") end
            -- Youtube sometimes fails for some reason. yey.
            msg(title)
        end
        if #url > 80 then
            local tin = ""
            local tin = http.request("http://tinyurl.com/api-create.php?url="..url)
            msg(tin)
        end
    elseif line:find("https://") then
        urlsaver(line)
        if line:find("https://[%w%p]+%s") == nil then
            local s,e = line:find("https://[%w%p]+")
            url = line:sub(s,e)
        else
            local s,e = line:find("https://[%w%p]+%s")
            url = line:sub(s,(e-1))
        end

        if #url > 80 then
            local tin = ""
            local tin = http.request("http://tinyurl.com/api-create.php?url="..url)
            if tin then msg(tin)
        end
    end

    elseif line:find("^!tinify") then
        local tinyurl = ""
        local tinyarg = line:gsub("^!tinify ", "")
        local tinyurl = http.request("http://tinyurl.com/api-create.php?url="..tinyarg)
        if tinyurl == nil then
            msg("Something might've gone terribly wrong.")
        else
            msg(tinyurl)
        end
        
    -- Actually tests if the searched function exists!
    elseif line:find("^!api") then
        local apimsg = ""
        local apibase = "http://www.lua.org/manual/5.1/manual.html#pdf-"
        local apiarg = line:gsub("^!api ","")
        -- Needed for checking that nil down there.
        local apifun = function()
                for i=1,#lapi.functions do
                    if apiarg == lapi.functions[i] then
                        return apibase .. apiarg
                    end
                end
            end
        local apimsg = apifun()
        if apimsg == nil then apimsg = "No such entry." end
        msg(apimsg)

    -- I was feeling awkward that day.
    elseif line:find("^!fortune") then
        local fh = io.popen("./fortunes_alone.awk")
        if not fh then
            msg("Sadness happened.")
        else
            local stuff = fh:read('*a')
            fh:close()
            msg(stuff)
        end

    elseif line:find("!judge") then
        msg("Tuomitaan Ilkkaa kaikki, minä kanssa!!")
    end
end

local rtest = function(str, testpat, message, freq)
    local freq = freq or 64 -- One eight of 512.
    local ret = ""
    if string.find(str,testpat) then
        if math.random(512) <= freq then    -- Adjust to your needs. Arbitrary value.
            ret = message
        else ret = "skip" end
    else ret = "skip" end
    if ret == "skip" then else msg(ret) end
end

local memegen = function(line)
    local memetbl = { "I don't always but when I do.. ",
                      "Business cat; our company has been through some tough times.. but we'll always land on our feet.",
                      "Ceiling cat is watching you..",
                      "Good guy Greg..",
                      "Philosoraptor..",

                  }

end


-- So AI, right, sure. Add a lot of stuff.
-- Semi-dynamic sentence generation, logical structuring!
estellefun.dospeak = function(line)
    local line = string.lower(line)

    if line:find("linux") then
        if (line:find("gnu%+linux") or line:find("gnu/linux")) == nil then
            rtest(line, "linux", "It's GNU+Linux, you moron!")
        end
    end

    rtest(line, "derp", "Muffins!")
    rtest(line, "party", "It's party time!")
    rtest(line, "huzzah", "The fun has been doubled!")
    rtest(line, "good idea", "I totally agree with you! Not.")
    rtest(line, "%s-vim%s-", "Vi is just one of emacs's major modes!")
    rtest(line, "%s-vi%+", "Vi is just one of emacs's major modes!")
    rtest(line, "lol", "Oh hai thur, Ceiling cat eatednings u an stuffs!")
    rtest(line, "%s-lua%s-", "I run on Lua! That's why I'm so hot I should be on fire!")

    -- "Speak randomly", infrequently.
    rtest(line, ".+", "I am participating!", 1)
    rtest(line, ".+", "Someday I will be a real person, too :<", 1)
    rtest(line, ".+", "Unacceptable!", 1)

    -- Local finnish stuff; do ignore.
    rtest(line, "bileet", "No. :<")
    rtest(line, "hässäkkä", "Aika mones hässäkkä, et selkeästikään tiedä mitä teet.")
end

return estellefun

