package sunag.sea3d.input
{
	import flash.display.Stage;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class Input
	{
		sea3dgp static const players:Object = {};
		sea3dgp static const codename:Object = {};		
		
		public static const LEFT:uint = 1;
		public static const RIGHT:uint = 2;
		public static const DOWN:uint = 4;
		public static const UP:uint = 8;
		
		public static const BTN_1:uint = 16;
		public static const BTN_2:uint = 32;
		public static const BTN_3:uint = 64;
		public static const BTN_4:uint = 128;
		public static const BTN_5:uint = 256;
		public static const BTN_6:uint = 512;
		//public static const BTN_7:uint = 1024;
		//public static const BTN_8:uint = 2048;
		//public static const BTN_9:uint = 4096;
		//public static const BTN_10:uint = 8192;
		
		//public static const START:uint = 16384;
		//public static const SELECT:uint = 32768;
		
		public static const AXIS_LEFT:uint = 65536;
		public static const AXIS_RIGHT:uint = 131072;
		public static const AXIS_DOWN:uint = 262114;
		public static const AXIS_UP:uint = 524288;
		
		sea3dgp static function init(stage:Stage):void
		{
			codename[LEFT] = 'left';
			codename[RIGHT] = 'right';
			codename[DOWN] = 'down';
			codename[UP] = 'up';
			
			codename[BTN_1] = 'btn1';
			codename[BTN_2] = 'btn2';
			codename[BTN_3] = 'btn3';
			codename[BTN_4] = 'btn4';
			codename[BTN_5] = 'btn5';
			codename[BTN_6] = 'btn6';
			
			codename[AXIS_LEFT] = 'axisLeft';
			codename[AXIS_RIGHT] = 'axisRight';
			codename[AXIS_DOWN] = 'axisDown';
			codename[AXIS_UP] = 'axisUp';
			
			// --
			
			codename['left'] = LEFT;
			codename['right'] = RIGHT;
			codename['down'] = DOWN;
			codename['up'] = UP;
			
			codename['btn1'] = BTN_1;
			codename['btn2'] = BTN_2;
			codename['btn3'] = BTN_3;
			codename['btn4'] = BTN_4;
			codename['btn5'] = BTN_5;
			codename['btn6'] = BTN_6;
			
			codename['axisLeft'] = AXIS_LEFT;
			codename['axisRight'] = AXIS_RIGHT;
			codename['axisDown'] = AXIS_DOWN;
			codename['axisUp'] = AXIS_UP;
		}
		
		sea3dgp static function update():void
		{
			for each(var input:InputBase in players)
			{
				input.update();
			}
		}
		
		public static function getPlayer(name:String="p1"):InputBase
		{
			return players[name];
		}
		
		public static function isDown(key:Number, player:String="p1"):Boolean
		{
			return players[player].isDown(key);
		}
		
		public static function getValue(key:Number, player:String="p1"):Number
		{
			return players[player].getValue(key);
		}
	}
}