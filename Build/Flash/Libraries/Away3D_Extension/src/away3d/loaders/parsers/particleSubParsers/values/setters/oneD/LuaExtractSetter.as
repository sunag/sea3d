package away3d.loaders.parsers.particleSubParsers.values.setters.oneD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	public class LuaExtractSetter extends SetterBase
	{
		private var _varName:String;
		private var _luaState:int;
		
		public function LuaExtractSetter(propName:String, varName:String)
		{
			super(propName);
			_varName = varName;
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			_luaState = prop.luaState;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			if (_luaState && _varName)
			{
				var luaState:int = prop.luaState;
				Lua.lua_getglobal(luaState, _varName);
				prop[_propName] = Lua.lua_tonumberx(luaState, -1, 0);
			}
			else
				prop[_propName] = 0;
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			if (_luaState && _varName)
			{
				Lua.lua_getglobal(_luaState, _varName);
				return Lua.lua_tonumberx(_luaState, -1, 0);
			}
			else
				return 0;
		}
	}
}
