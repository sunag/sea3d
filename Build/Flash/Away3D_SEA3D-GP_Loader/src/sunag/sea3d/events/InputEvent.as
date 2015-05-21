package sunag.sea3d.events
{
	

	public class InputEvent extends Event
	{
		public static const INPUT_DOWN:String = "inputDown";
		public static const INPUT_UP:String = "inputUp";
		
		public function InputEvent(type:String)
		{
			super(type);			
		}
	}
}