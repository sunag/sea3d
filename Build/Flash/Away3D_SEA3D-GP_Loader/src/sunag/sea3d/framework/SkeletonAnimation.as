package sunag.sea3d.framework
{
	import flash.net.URLRequest;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.data.JointPose;
	import away3d.animators.data.SkeletonPose;
	import away3d.animators.nodes.AnimationNodeBase;
	import away3d.animators.nodes.SkeletonClipNode;
	
	import sunag.sea3dgp;
	import sunag.sea3d.config.ConfigBase;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.events.Event;
	import sunag.sea3d.loader.Scene3DLoader;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEASkeletonAnimation;

	use namespace sea3dgp;
	
	public class SkeletonAnimation extends Animation
	{
		public static function getAsset(name:String):SkeletonAnimation
		{
			return Animation.getAsset(name) as SkeletonAnimation;
		}
		
		sea3dgp var clipNodes:Vector.<SkeletonClipNode>;
		sea3dgp var scopeGPU:SkeletonAnimationSet;
		sea3dgp var scopeCPU:SkeletonAnimationSet;
		
		sea3dgp function creatAnimationSet(jointPerVertex:int=4, usesGPU:Boolean=true):SkeletonAnimationSet
		{
			var node:SkeletonClipNode;
			
			if (usesGPU)
			{
				if (!scopeGPU)
				{
					scopeGPU = new SkeletonAnimationSet(jointPerVertex);					
					
					for each(node in clipNodes)
						scopeGPU.addAnimation(node);
				}
				
				return scopeGPU;
			}
			else
			{
				if (!scopeCPU)
				{
					scopeCPU = new SkeletonAnimationSet(jointPerVertex);					
					
					for each(node in clipNodes)
						scopeCPU.addAnimation(node);
				}
				
				return scopeCPU;
			}
						
			return null;
		}
		
		public function loadAnimation(name:String, url:String, onComplete:Function=null):void
		{
			var config:ConfigBase = new ConfigBase();				
			var loader:Scene3DLoader = Scene3DLoader.create(url, name, config);
			var me:SkeletonAnimation = this;
			
			loader.addCallback(function(assets:Object):void
			{
				for each(var asset:Asset in assets)
				{
					if (asset is SkeletonAnimation)
					{
						merger(asset as SkeletonAnimation);
					}
				}
				
				if (onComplete)
					onComplete(me);
			});
			
			loader.load( new URLRequest( url ) );		
			
			SEA3DGP.manager.addLoader( loader );
		}
		
		sea3dgp function invalidate():void
		{			
			if (scopeGPU)
			{
				scopeGPU.dispose();
				scopeGPU = null;
			}
			
			if (scopeCPU)
			{
				scopeCPU.dispose();
				scopeCPU = null;
			}
		}
		
		public function merger(anm:SkeletonAnimation):void
		{
			invalidate();
			
			for each(var node:SkeletonClipNode in anm.clipNodes)
			{
				clipNodes[clipNodes.length] = node;
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override public function get names():Array
		{
			var names:Array = [];
			
			for each(var anm:AnimationNodeBase in (scopeGPU || scopeCPU).animations)			
				names.push( anm.name );			
			
			return names;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	SKELETON ANIMATION
			//
			
			var anm:SEASkeletonAnimation = sea as SEASkeletonAnimation;
			
			clipNodes = new Vector.<SkeletonClipNode>();
			
			for each(var seq:Object in anm.sequence)		
			{
				var clip:SkeletonClipNode = new SkeletonClipNode();
				
				clip.name = seq.name;
				clip.looping = seq.repeat;
				clip.frameRate = anm.frameRate;
				
				var start:int = seq.start;
				var end:int = start + seq.count;
				
				for (var i:int=start;i<end;i++)
				{
					var pose:Array = anm.pose[i];
					var len:uint = pose.length;
					
					var sklPose:SkeletonPose = new SkeletonPose();			
					sklPose.jointPoses.length = len;
					
					for (var j:int=0;j<len;j++)
					{				
						var jointPose:JointPose = sklPose.jointPoses[j] = new JointPose();
						var jointData:Object = pose[j];
						
						jointPose.translation.x = jointData.x;
						jointPose.translation.y = jointData.y;
						jointPose.translation.z = jointData.z;
						
						jointPose.orientation.x = jointData.qx;
						jointPose.orientation.y = jointData.qy;
						jointPose.orientation.z = jointData.qz;
						jointPose.orientation.w = jointData.qw;
					}
					
					clip.addFrame(sklPose);				
				}
				
				clipNodes[clipNodes.length] = clip;
			}
		}
	}
}