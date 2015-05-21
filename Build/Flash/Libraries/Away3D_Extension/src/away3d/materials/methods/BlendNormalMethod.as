package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.textures.Texture2DBase;
	
	import flash.utils.getTimer;
	
	use namespace arcane;	
	
	public class BlendNormalMethod extends SimpleWaterNormalMethod
	{
		private var _animate:Boolean;
		
		private var _time:Number = 0;
		
		private var _animate1OffsetX : Number = .1;
		private var _animate1OffsetY : Number = 0;
		private var _animate2OffsetX : Number = .2;
		private var _animate2OffsetY : Number = 0;
		
		public function BlendNormalMethod(waveMap1:Texture2DBase, waveMap2:Texture2DBase, animate:Boolean=true)
		{
			super(waveMap1, waveMap2);
			
			_animate = animate;
		}
		
		public function set animate(val:Boolean):void
		{
			_animate = val;
		}
		
		public function get animate():Boolean
		{
			return _animate;
		}
		
		public function get animate1OffsetX() : Number
		{
			return _animate1OffsetX;
		}
		
		public function set animate1OffsetX(value : Number) : void
		{
			_animate1OffsetX = value;
		}
		
		public function get animate1OffsetY() : Number
		{
			return _animate1OffsetY;
		}
		
		public function set animate1OffsetY(value : Number) : void
		{
			_animate1OffsetY = value;
		}
		
		public function get animate2OffsetX() : Number
		{
			return _animate2OffsetX;
		}
		
		public function set animate2OffsetX(value : Number) : void
		{
			_animate2OffsetX = value;
		}
		
		public function get animate2OffsetY() : Number
		{
			return _animate2OffsetY;
		}
		
		public function set animate2OffsetY(value : Number) : void
		{
			_animate2OffsetY = value;
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			if (_animate)
			{
				var time:Number = getTimer(),
					delta:Number = (time - _time) / 1000;
				
				water1OffsetX += animate1OffsetX * delta;
				water1OffsetY += animate1OffsetY * delta;
				water2OffsetX += animate2OffsetX * delta;
				water2OffsetY += animate2OffsetY * delta;	
				
				_time = time;
			}
			
			super.activate(vo, stage3DProxy);
		}
	}
}