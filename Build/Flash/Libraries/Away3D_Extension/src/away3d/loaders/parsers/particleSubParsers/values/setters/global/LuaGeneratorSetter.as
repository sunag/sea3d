package away3d.loaders.parsers.particleSubParsers.values.setters.global
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	public class LuaGeneratorSetter extends SetterBase
	{
		private var _luaState:int;
		private var _code:String;
		
		public function LuaGeneratorSetter(propName:String, code:String)
		{
			super(propName);
			_code = code;
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			_luaState = Lua.luaL_newstate();
			Lua.luaL_openlibs(_luaState);
			Lua.lua_getglobal(_luaState, "math");
			Lua.lua_getfield(_luaState, -1, "randomseed");
			Lua.lua_remove(_luaState, -2);
			Lua.lua_pushnumber(_luaState, Math.random() * 10000);
			Lua.lua_callk(_luaState, 1, 0, 0, null);
			prop.luaState = _luaState;
			
			var err:int = Lua.luaL_loadstring(_luaState, _code);
			if (err)
				onError("Lua Parse Error " + err + ": " + Lua.luaL_checklstring(_luaState, 1, 0));
			Lua.lua_setglobal(_luaState, "__main");
		}
		
		private function onError(e:*):void
		{
			trace(e);
			Lua.lua_close(_luaState);
			_luaState = 0;
			throw(new Error(e));
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			Lua.lua_pushnumber(_luaState, prop.index);
			Lua.lua_setglobal(_luaState, "index");
			Lua.lua_pushnumber(_luaState, prop.total);
			Lua.lua_setglobal(_luaState, "total");
			Lua.lua_getglobal(_luaState, "__main");
			var err:int = Lua.lua_pcallk(_luaState, 0, Lua.LUA_MULTRET, 0, 0, null);
			if (err)
			{
				onError("Lua Execute Error " + err + ": " + Lua.luaL_checklstring(_luaState, 1, 0));
			}
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			Lua.lua_close(_luaState);
			_luaState = 0;
		}
	}
}
