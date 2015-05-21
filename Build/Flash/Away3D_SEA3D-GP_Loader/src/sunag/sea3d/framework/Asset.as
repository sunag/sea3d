package sunag.sea3d.framework
{
	import sunag.sea3dgp;
	import sunag.sea3d.engine.IDisposable;
	import sunag.sea3d.events.AssetEvent;
	import sunag.sea3d.events.EventDispatcher;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class Asset extends EventDispatcher implements IDisposable
	{
		sea3dgp static var INSTANCE:uint = 0;
		
		sea3dgp var _name:String;		
		sea3dgp var _type:String;
		sea3dgp var _scene:Scene3D;		
		
		public var tag:*;
		
		public function Asset(type:String):void
		{
			_type = type;
			_name = 'asset' + INSTANCE++;
		}
		
		sea3dgp function setScene(scene:Scene3D):void
		{
			if (_scene)
			{
				delete _scene.library[_type+_name];
				
				_scene.list.splice( _scene.list.indexOf(this), 1);								
			}
			
			if ((_scene = scene))
			{
				_scene.list.push( this );
				
				updateName();
			}
		}
				
		sea3dgp function updateName():void
		{
			var lib:Object = _scene.library;			
			
			while( lib[_type+_name] != null )
			{
				var s:int = _name.search(/[0-9]+$/),
					l:int = _name.substring(s).length;
				
				if (s > -1)
				{
					var n:String = (parseInt(_name.substring(s)) + 1).toString();
					
					while (n.length < l)
						n = '0' + n;
					
					_name = _name.substring(0, s) + n;					
				}
				else _name += "1";
			}
						
			lib[_type+_name] = this;
		}
		
		sea3dgp function load(sea:SEAObject):void
		{
			name = sea.name;
			
			sea.tag = this;
		}
		
		public function set name(val:String):void
		{
			if (name == val) return;
			
			if (_scene)
			{
				delete _scene.library[_type+_name];
				
				_name = val;
				
				updateName();
				
				dispatchEvent(new AssetEvent(AssetEvent.RENAME));
			}
			else
			{
				_name = val as String;
			}
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get scene():Scene3D
		{
			return _scene;
		}
		
		public function clone():Asset
		{
			trace("Clone not implemented:", this);
			return this;			
		}
		
		sea3dgp function copyFrom(asset:Asset):void
		{
			name = asset.name;
		}
		
		public function dispose():void
		{
			setScene( null );
		}
	}
}