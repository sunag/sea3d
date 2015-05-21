package sunag.sea3d.modules
{
	import flash.geom.Vector3D;
	
	import away3d.entities.SegmentSet;
	import away3d.primitives.LineSegment;
	import away3d.primitives.WireframeCube;
	import away3d.sea3d.animation.DummyAnimation;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.objects.IAnimator;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEADummy;
	import sunag.sea3d.objects.SEALine;

	use namespace sunag;
	
	public class HelperModule extends HelperModuleBase
	{
		public static var COLOR:uint = 0x9AB9E5;
		
		protected var _line:Vector.<SegmentSet>;
		protected var _dummy:Vector.<WireframeCube>;		
		
		sunag var sea3d:SEA3D;
		
		public function HelperModule()
		{			
			regRead(SEALine.TYPE, readLine);					
			regRead(SEADummy.TYPE, readDummy);						
		}
		
		override sunag function reset():void
		{
			_line = null;
			_dummy = null;			
		}
		
		public function get lines():Vector.<SegmentSet>
		{
			return _line;
		}
		
		public function get dummys():Vector.<WireframeCube>
		{
			return _dummy;
		}
		
		protected function readDummy(sea:SEADummy):void
		{	
			var dummy:WireframeCube = new WireframeCube(sea.width, sea.height, sea.depth, COLOR, 1);
			
			dummy.transform = sea.transform;
			
			//
			//	Animations
			//
			
			for each(var anm:Object in sea.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEAAnimation)
				{
					sea3d.addAnimation				
						(
							new DummyAnimation(dummy, (tag as SEAAnimation).tag),
							sea.name, anm
						);
				}
			}
			
			sea3d.addSceneObject(sea, dummy);
			
			_dummy ||= new Vector.<WireframeCube>();
			_dummy.push(this.sea.object[sea.filename] = sea.tag = dummy);
		}
		
		override public function dispose():void
		{
			for each(var seg:SegmentSet in _line)
			{
				seg.dispose();
			}	
			
			for each(var dummy:WireframeCube in _dummy)
			{
				dummy.dispose();
			}						
		}
		
		protected function readLine(sea:SEALine):void
		{		
			var data:Vector.<Vector3D> = sea.toVector3D();
			
			var obj3d:SegmentSet = new SegmentSet();
			
			for(var i:int=1;i<data.length;i++)			
				obj3d.addSegment(new LineSegment(data[i-1], data[i], COLOR, COLOR, 1));				
			
			obj3d.name = sea.name;
			obj3d.transform = sea.transform;
							
			sea3d.object[sea.filename] = sea.tag = obj3d;
			
			sea3d.addSceneObject(sea, obj3d);
		}
		
		public function getLine(name:String):SegmentSet
		{
			return sea.object[name + ".line"];
		}
		
		public function getDummy(name:String):WireframeCube
		{
			return sea.object[name  + ".dmy"];
		}
		
		override sunag function init(sea:SEA):void
		{
			this.sea = sea;
			sea3d = sea as SEA3D;
		}
	}
}