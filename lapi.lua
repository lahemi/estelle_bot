
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

--[[local C_API = { 
    "lua_Alloc", "lua_CFunction", "lua_Debug",
    "lua_Hook", "lua_Integer", "lua_Number",
    "lua_Reader", "lua_State", "lua_Unsigned",
    "lua_Writer", "lua_absindex", "lua_arith",
    "lua_atpanic", "lua_call", "lua_callk",
    "lua_checkstack", "lua_close", "lua_compare",
    "lua_concat", "lua_copy", "lua_createtable",
    "lua_dump", "lua_error", "lua_gc",
    "lua_getallocf", "lua_getctx", "lua_getfield",
    "lua_getglobal", "lua_gethook", "lua_gethookcount",
    "lua_gethookmask", "lua_getinfo", "lua_getlocal",
    "lua_getmetatable", "lua_getstack", "lua_gettable",
    "lua_gettop", "lua_getupvalue", "lua_getuservalue",
    "lua_insert", "lua_isboolean", "lua_iscfunction",
    "lua_isfunction", "lua_islightuserdata", "lua_isnil",
    "lua_isnone", "lua_isnoneornil", "lua_isnumber",
    "lua_isstring", "lua_istable", "lua_isthread",
    "lua_isuserdata", "lua_len", "lua_load",
    "lua_newstate", "lua_newtable", "lua_newthread",
    "lua_newuserdata", "lua_next", "lua_pcall",
    "lua_pcallk", "lua_pop", "lua_pushboolean",
    "lua_pushcclosure", "lua_pushcfunction", "lua_pushfstring",
    "lua_pushglobaltable", "lua_pushinteger", "lua_pushlightuserdata",
    "lua_pushliteral", "lua_pushlstring", "lua_pushnil",
    "lua_pushnumber", "lua_pushstring", "lua_pushthread",
    "lua_pushunsigned", "lua_pushvalue", "lua_pushvfstring",
    "lua_rawequal", "lua_rawget", "lua_rawgeti",
    "lua_rawgetp", "lua_rawlen", "lua_rawset",
    "lua_rawseti", "lua_rawsetp", "lua_register",
    "lua_remove", "lua_replace", "lua_resume",
    "lua_setallocf", "lua_setfield", "lua_setglobal",
    "lua_sethook", "lua_setlocal", "lua_setmetatable",
    "lua_settable", "lua_settop", "lua_setupvalue",
    "lua_setuservalue", "lua_status", "lua_toboolean",
    "lua_tocfunction", "lua_tointeger", "lua_tointegerx",
    "lua_tolstring", "lua_tonumber", "lua_tonumberx",
    "lua_topointer", "lua_tostring", "lua_tothread",
    "lua_tounsigned", "lua_tounsignedx", "lua_touserdata",
    "lua_type", "lua_typename", "lua_upvalueid",
    "lua_upvalueindex", "lua_upvaluejoin", "lua_version",
    "lua_xmove", "lua_yield", "lua_yieldk"
}
    
local auxiliary_library = {  
    "luaL_Buffer", "luaL_Reg", "luaL_addchar",
    "luaL_addlstring", "luaL_addsize", "luaL_addstring",
    "luaL_addvalue", "luaL_argcheck", "luaL_argerror",
    "luaL_buffinit", "luaL_buffinitsize", "luaL_callmeta",
    "luaL_checkany", "luaL_checkint", "luaL_checkinteger",
    "luaL_checklong", "luaL_checklstring", "luaL_checknumber",
    "luaL_checkoption", "luaL_checkstack", "luaL_checkstring",
    "luaL_checktype", "luaL_checkudata", "luaL_checkunsigned",
    "luaL_checkversion", "luaL_dofile", "luaL_dostring",
    "luaL_error", "luaL_execresult", "luaL_fileresult",
    "luaL_getmetafield", "luaL_getmetatable", "luaL_getsubtable",
    "luaL_gsub", "luaL_len", "luaL_loadbuffer",
    "luaL_loadbufferx", "luaL_loadfile", "luaL_loadfilex",
    "luaL_loadstring", "luaL_newlib", "luaL_newlibtable",
    "luaL_newmetatable", "luaL_newstate", "luaL_openlibs",
    "luaL_optint", "luaL_optinteger", "luaL_optlong",
    "luaL_optlstring", "luaL_optnumber", "luaL_optstring",
    "luaL_optunsigned", "luaL_prepbuffer", "luaL_prepbuffsize",
    "luaL_pushresult", "luaL_pushresultsize", "luaL_ref",
    "luaL_requiref", "luaL_setfuncs", "luaL_setmetatable",
    "luaL_testudata", "luaL_tolstring", "luaL_traceback",
    "luaL_typename", "luaL_unref", "luaL_where"
}]]--
