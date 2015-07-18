package away3d.materials.custom
{
	public class Vector4 extends Data
	{				
		public function Vector4(name:String, data:Vector.<Number>, offset:uint=0)
		{
			super(name, data, offset);
		}
		
		public function set x(val:Number):void
		{
			_data[_offset] = val;
		}
		
		public function get x():Number
		{
			return _data[_offset];
		}
		
		public function set y(val:Number):void
		{
			_data[_offset+1] = val;
		}
		
		public function get y():Number
		{
			return _data[_offset+1];
		}
		
		public function set z(val:Number):void
		{
			_data[_offset+2] = val;
		}
		
		public function get z():Number
		{
			return _data[_offset+2];
		}
		
		public function set w(val:Number):void
		{
			_data[_offset+3] = val;
		}
		
		public function get w():Number
		{
			return _data[_offset+3];
		}
		
		public function set color(val:uint):void
		{			
			_data[_offset] = (val & 0xff) / 0xff;
			_data[_offset+1] = ((val >> 8) & 0xff) / 0xff;
			_data[_offset+2] = ((val >> 16) & 0xff) / 0xff;
			_data[_offset+3] = ((val >> 24) & 0xff) / 0xff;
		}
		
		public function get color():uint
		{
			return _data[_offset] | (_data[_offset+1] << 8) | (_data[_offset+2] << 16) | (_data[_offset+3] << 24);
		}				
	}
}