
lapi = {}

lapi.functions = {
    "_G", "_VERSION", "assert", "collectgarbage", "dofile",
    "error", "getmetatable", "ipairs", "load", "loadfile",
    "next", "pairs", "pcall", "print", "rawequal", "rawget",
    "rawlen", "rawset", "require", "select", "setmetatable",
    "tonumber", "tostring", "type", "xpcall", "bit32.arshift",
    "bit32.band", "bit32.bnot", "bit32.bor", "bit32.btest",
    "bit32.bxor", "bit32.extract", "bit32.lrotate",
    "bit32.lshift", "bit32.replace", "bit32.rrotate",
    "bit32.rshift", "coroutine.create", "coroutine.resume",
    "coroutine.running", "coroutine.status", "coroutine.wrap",
    "coroutine.yield", "debug.debug", "debug.getuservalue",
    "debug.gethook", "debug.getinfo", "debug.getlocal",
    "debug.getmetatable", "debug.getregistry", "debug.getupvalue",
    "debug.setuservalue", "debug.sethook", "debug.setlocal",
    "debug.setmetatable", "debug.setupvalue", "debug.traceback",
    "debug.upvalueid", "debug.upvaluejoin", "file:close",
    "file:flush", "file:lines", "file:read", "file:seek",
    "file:setvbuf", "file:write", "io.close", "io.flush",
    "io.input", "io.lines", "io.open", "io.output",
    "io.popen", "io.read", "io.stderr", "io.stdin",
    "io.stdout", "io.tmpfile", "io.type", "io.write",
    "math.abs", "math.acos", "math.asin", "math.atan",
    "math.atan2", "math.ceil", "math.cos", "math.cosh",
    "math.deg", "math.exp", "math.floor", "math.fmod",
    "math.frexp", "math.huge", "math.ldexp", "math.log",
    "math.max", "math.min", "math.modf", "math.pi",
    "math.pow", "math.rad", "math.random", "math.randomseed",
    "math.sin", "math.sinh", "math.sqrt", "math.tan",
    "math.tanh", "os.clock", "os.date", "os.difftime",
    "os.execute", "os.exit", "os.getenv", "os.remove",
    "os.rename", "os.setlocale", "os.time", "os.tmpname",
    "package.config", "package.cpath", "package.loaded",
    "package.loadlib", "package.path", "package.preload",
    "package.searchers", "package.searchpath", "string.byte",
    "string.char", "string.dump", "string.find",
    "string.format", "string.gmatch", "string.gsub",
    "string.len", "string.lower", "string.match",
    "string.rep", "string.reverse", "string.sub",
    "string.upper", "table.concat", "table.insert",
    "table.pack", "table.remove", "table.sort",
    "table.unpack"
}

return lapi

