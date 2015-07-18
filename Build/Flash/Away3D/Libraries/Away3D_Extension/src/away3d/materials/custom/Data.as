package away3d.materials.custom
{
	public class Data
	{
		private var _name:String;
		
		protected var _offset:uint;
		protected var _data:Vector.<Number>;
		
		public function Data(name:String, data:Vector.<Number>, offset:uint=0)
		{
			_name = name;
			_data = data;
			_offset = offset;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get offset():uint
		{
			return _offset;
		}
		
		public function get data():Vector.<Number>
		{
			return _data;
		}
	}
}