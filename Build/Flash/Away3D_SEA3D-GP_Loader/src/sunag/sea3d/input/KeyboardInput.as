package sunag.sea3d.input 
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class KeyboardInput extends InputBase
	{	
		private var codename:Object = {};
		
		public function KeyboardInput(config:Object=null)
		{
			 setConfig( {
				left : 'a',
				right : 'd',
				down : 's',
				up : 'w',
				
				btn1 : 'u',
				btn2 : 'i',
				btn3 : 'o',
				btn4 : 'j',
				btn5 : 'k',
				btn6 : 'l',
				
				axisLeft : 'left',
				axisRight : 'right',
				axisDown : 'down',
				axisUp : 'up'
			} );
		}
		
		private function setConfig(config:Object):void
		{
			for(var name:String in config)
			{	
				codename[name] = getKeyCode(config[name]);	
			}
		}
		
		private function getKeyCode(name:String):Number
		{		
			return Keyboard[name.toUpperCase()];
		}
		
		override sea3dgp function update():void
		{
			for(var name:String in input)
			{
				this[name] = isKeyDown(codename[name]);
			}
			
			super.update();
		}
		
		//
		//	STATIC
		//
		
		sea3dgp static var stage:Stage;
		sea3dgp static var keyState:Object = {};
		
		sea3dgp static function init(stage:Stage):void
		{
			KeyboardInput.stage = stage;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		sea3dgp static function onKeyDown(e:KeyboardEvent):void
		{
			keyState[e.keyCode] = true;
		}
		
		sea3dgp static function onKeyUp(e:KeyboardEvent):void
		{
			keyState[e.keyCode] = false;
		}
		
		sea3dgp static function isKeyDown(keyCode:int):Boolean
		{						
			return keyState[keyCode];
		}
		
		public static function isDown(keyCode:Number):Boolean
		{
			return keyState[keyCode];
		}
	}
}