package sunag.sea3d.framework
{
	import away3d.audio.Sound3D;
	import away3d.sea3d.animation.Sound3DAnimation;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEASoundPoint;

	use namespace sea3dgp;
	
	public class PointSound extends Sound3DBase
	{
		sea3dgp var pointSound:Sound3D;
		
		public function PointSound()
		{
			super(pointSound = new Sound3D(), Sound3DAnimation);
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	POINT SOUND
			//
			
			var seaSnd:SEASoundPoint = sea as SEASoundPoint;
			
			pointSound.scaleDistance = seaSnd.distance;
			pointSound.position = seaSnd.position;
		}
		
		public function set distance(val:Number):void
		{
			pointSound.scaleDistance = val;
		}
		
		public function get distance():Number
		{
			return pointSound.scaleDistance;
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom(asset);
			
			var s:PointSound = asset as PointSound;
			pointSound.scaleDistance = s.pointSound.scaleDistance;			
		}	
		
		override public function clone(force:Boolean=false):Asset
		{
			var sound:PointSound = new PointSound();
			sound.copyFrom(this);
			return sound;
		}
	}
}