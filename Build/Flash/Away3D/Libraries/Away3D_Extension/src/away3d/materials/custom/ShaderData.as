package away3d.materials.custom
{
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	
	import away3d.arcane;

	use namespace arcane;
	
	public class ShaderData
	{
		arcane var _vertexAttrib:Object;
		arcane var _vertexStruct:Vector.<Data>;
		arcane var _vertexBuffer:Vector.<uint>;
		arcane var _vertexData:Vector.<Number>;
		arcane var _vertexOffset:uint = 0;
		arcane var _vertexAsm:String;
		
		arcane var _fragmentAttrib:Object;				
		arcane var _fragmentStruct:Vector.<Data>;				
		arcane var _fragmentTexture:Vector.<uint>;
		arcane var _fragmentData:Vector.<Number>;
		arcane var _fragmentOffset:uint = 0;
		arcane var _fragmentAsm:String;						
		
		arcane var _depthMask:Boolean = true;
		arcane var _enabledBlend:Boolean = false;
		
		arcane var _srcBlend:String = Context3DBlendFactor.ONE;
		arcane var _destBlend:String = Context3DBlendFactor.ZERO;
		
		arcane var _depthCompareMode:String = Context3DCompareMode.LESS_EQUAL;
		
		arcane var vertexIndex:int = -1;
		arcane var normalIndex:int = -1;
		arcane var normalMatrixIndex:int = -1;
		arcane var tangentIndex:int = -1;
		arcane var colorIndex:int = -1;
		arcane var secondaryColorIndex:int = -1;
		arcane var uvIndex:int = -1;
		arcane var secondaryUVIndex:int = -1;
		
		arcane var projectionMatrixIndex:int = -1;
		arcane var modelViewMatrixIndex:int = -1;
		arcane var modelViewProjectionMatrixIndex:int = -1;		
		
		public function getVertVec4(name:String):Vector4
		{
			return _vertexAttrib[name];
		}
		
		public function getFragVec4(name:String):Vector4
		{
			return _fragmentAttrib[name];
		}
		
		public function get vertexStruct():Vector.<Data>
		{
			return _vertexStruct;
		}
		
		public function get fragmentStruct():Vector.<Data>
		{
			return _fragmentStruct;
		}
		
		public function get depthCompareMode() : String
		{
			return _depthCompareMode;
		}
		
		public function set depthCompareMode(value : String) : void
		{
			_depthCompareMode = value;
		}
		
		public function set enabledBlend(val:Boolean):void
		{
			_enabledBlend = val;
		}
		
		public function get enabledBlend():Boolean
		{
			return _enabledBlend;
		}
		
		public function set depthMask(val:Boolean):void
		{
			_depthMask = val;
		}
		
		public function get depthMask():Boolean
		{
			return _depthMask;
		}
		
		public function set srcBlend(val:String):void
		{
			_srcBlend = val;
		}
		
		public function get srcBlend():String
		{
			return _destBlend;
		}
		
		public function set destBlend(val:String):void
		{
			_destBlend = val;
		}
		
		public function get destBlend():String
		{
			return _destBlend;
		}
	}
}