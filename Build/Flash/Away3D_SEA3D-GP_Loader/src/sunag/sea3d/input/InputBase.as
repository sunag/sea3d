package sunag.sea3d.input
{
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class InputBase
	{
		sea3dgp var left:Boolean = false;
		sea3dgp var right:Boolean = false;
		sea3dgp var down:Boolean = false;
		sea3dgp var up:Boolean = false;
		
		sea3dgp var btn1:Boolean = false;
		sea3dgp var btn2:Boolean = false;
		sea3dgp var btn3:Boolean = false;
		sea3dgp var btn4:Boolean = false;
		sea3dgp var btn5:Boolean = false;
		sea3dgp var btn6:Boolean = false;
		
		sea3dgp var axisLeft:Boolean = false;
		sea3dgp var axisRight:Boolean = false;
		sea3dgp var axisDown:Boolean = false;
		sea3dgp var axisUp:Boolean = false;
		
		sea3dgp var id:String;
		sea3dgp var input:uint = 0;		
						
		sea3dgp function update():void
		{
			input = 0;
			
			if (left) input |= Input.LEFT;
			if (right) input |= Input.RIGHT;
			if (down) input |= Input.DOWN;
			if (up) input |= Input.UP;
			
			if (btn1) input |= Input.BTN_1;
			if (btn2) input |= Input.BTN_2;
			if (btn3) input |= Input.BTN_3;
			if (btn4) input |= Input.BTN_4;
			if (btn5) input |= Input.BTN_5;
			if (btn6) input |= Input.BTN_6;
			
			if (axisLeft) input |= Input.AXIS_LEFT;
			if (axisRight) input |= Input.AXIS_RIGHT;
			if (axisDown) input |= Input.AXIS_DOWN;
			if (axisUp) input |= Input.AXIS_UP;
		}
		
		public function isDown(key:Number):Boolean
		{
			return this[ Input.codename[key] ];
		}
		
		public function getValue(key:Number):Number
		{
			return int( isDown(key) );
		}
	}
}