package away3d.loaders.parsers.particleSubParsers.values.setters.oneD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	public class OneDCurveSetter extends SetterBase
	{
		protected var _anchors:Vector.<Anchor>;
		
		public function OneDCurveSetter(propName:String, anchorDatas:Array)
		{
			super(propName);
			var len:int = anchorDatas.length;
			_anchors = new Vector.<Anchor>(len, true);
			for (var i:int; i < len; i++)
			{
				_anchors[i] = new Anchor(anchorDatas[i].x, anchorDatas[i].y, anchorDatas[i].type);
			}
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			//todo:optimise
			var percent:Number = index / total;
			var i:int;
			for (; i < _anchors.length - 1; i++)
			{
				if (_anchors[i + 1].x > percent)
				{
					switch (_anchors[i].type)
					{
						case Anchor.LINEAR:
							return _anchors[i].y + (percent - _anchors[i].x) / (_anchors[i + 1].x - _anchors[i].x) * (_anchors[i + 1].y - _anchors[i].y);
							break;
						case Anchor.CONST:
							return _anchors[i].y;
							break;
					}
				}
			}
			return _anchors[i].y;
		}
	}
}



class Anchor
{
	//TODO: add the bezier curve support
	public static const LINEAR:int = 0;
	public static const CONST:int = 1;
	public static const BEZIER:int = 2;
	
	public var x:Number;
	public var y:Number;
	public var type:int;
	
	public function Anchor(x:Number, y:Number, type:int)
	{
		this.x = x;
		this.y = y;
		this.type = type;
	}
}
