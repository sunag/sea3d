package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import away3d.animator.IMorphAnimator;
	import away3d.animator.MorphAnimationSet;
	import away3d.animator.MorphAnimator;
	import away3d.animator.MorphGeometry;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimatorProxy;
	import away3d.animators.VertexAnimator;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.states.SkeletonClipState;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.animators.transitions.CrossfadeTransitionState;
	import away3d.core.base.SubMesh;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.events.AnimationStateEvent;
	import away3d.sea3d.animation.MeshAnimation;
	import away3d.sea3d.animation.MorphAnimation;
	import away3d.tools.SkeletonTools;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.engine.TopLevel;
	import sunag.sea3d.events.AnimationEvent;
	import sunag.sea3d.events.Event;
	import sunag.sea3d.objects.IAnimator;
	import sunag.sea3d.objects.SEAMaterialBase;
	import sunag.sea3d.objects.SEAMesh;
	import sunag.sea3d.objects.SEAModifier;
	import sunag.sea3d.objects.SEAMorph;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEASkeleton;
	import sunag.sea3d.objects.SEASkeletonAnimation;

	use namespace sea3dgp;
	
	public class Mesh extends Object3D		
	{					
		sea3dgp var mesh:away3d.entities.Mesh;
		sea3dgp var skinGPU:Boolean = SEA3DGP.config.skinGPU;
		sea3dgp var morphGPU:Boolean = SEA3DGP.config.morphGPU;
		
		sea3dgp var multiMtl:Array;
		sea3dgp var mtl:Material;
		
		sea3dgp var skeletonRef:Mesh;
		sea3dgp var sklRefAnimator:SkeletonAnimatorProxy;
		sea3dgp var skl:Skeleton;
		sea3dgp var skeletonAnm:SkeletonAnimation;		
		sea3dgp var sklAnimator:SkeletonAnimator;		
		
		sea3dgp var geo:GeometryBase;
		
		sea3dgp var vertexAnm:VertexAnimation; 
		sea3dgp var vertexAnimator:VertexAnimator;
		
		sea3dgp var morphAnm:sunag.sea3d.framework.MorphAnimation;
		sea3dgp var morphAnimator:away3d.sea3d.animation.MorphAnimation;
		
		sea3dgp var mph:Morph;		
		sea3dgp var morpher:IMorphAnimator;
		sea3dgp var joints:Dictionary;
		
		public function Mesh(geometry:GeometryBase=null, material:Material=null)
		{
			super(mesh = new away3d.entities.Mesh( GeometryBase.NULL ), MeshAnimation);
			
			mesh.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			mesh.shaderPickingDetails = false;
			
			this.geometry = geometry;
			this.material = material;			
		}
		
		//
		//	SKELETON REFERENCE
		//
		
		public function set skeletonReference(val:Mesh):void
		{
			if (skeletonRef)
			{
				skeletonRef.removeEventListener(Event.ANIMATOR, onSkeletonReference);
			}
			
			skeletonRef = val;	
			
			if (skeletonRef)
			{
				skeletonRef.addEventListener(Event.ANIMATOR, onSkeletonReference);
			}
			
			updateAnimation();
		}
		
		public function get skeletonReference():Mesh
		{
			return skeletonRef;
		}
		
		private function onSkeletonReference(e:Event):void
		{
			updateAnimation();
		}
		
		//
		//	SKELETON ANIMATION
		//
		
		public function set skeleton(val:Skeleton):void
		{
			if (skl == val) return;
			skl = val;
			updateAnimation();
		}
		
		public function get skeleton():Skeleton
		{
			return skl;
		}
		
		public function set skeletonAnimation(val:SkeletonAnimation):void
		{
			if (skeletonAnm)
			{
				skeletonAnm.removeEventListener(Event.COMPLETE, onSkeletonAnimation);
			}
			
			skeletonAnm = val;	
			
			if (skeletonAnm)
			{
				skeletonAnm.addEventListener(Event.COMPLETE, onSkeletonAnimation);
			}
			
			updateAnimation();
		}
		
		public function get skeletonAnimation():SkeletonAnimation
		{
			return skeletonAnm;
		}
		
		private function onSkeletonAnimation(e:Event):void
		{
			updateAnimation();
		}
		
		public function playSkeletonAnimation(name:String, blendSpeed:Number=0, offset:Number=NaN):void
		{
			sklAnimator.play(name, new CrossfadeTransition(blendSpeed), offset);
			sklAnimator.activeAnimation.addEventListener(AnimationStateEvent.PLAYBACK_COMPLETE, onSklAnmComplete);
			SEA3DGP.addAnimator(sklAnimator);
		}
		
		public function stopSkeletonAnimation():void
		{
			if (sklAnimator.activeAnimation)			
				sklAnimator.activeAnimation.removeEventListener(AnimationStateEvent.PLAYBACK_COMPLETE, onSklAnmComplete);			
			SEA3DGP.removeAnimator(sklAnimator);
		}
		
		public function set skeletonBlendMode(blendMode:String):void
		{
			TopLevel.warn('Unavailable: Mesh.setSkeletonBlendMode');
		}
		
		public function get skeletonBlendMode():String
		{
			return AnimationBlendMode.LINEAR;
		}
		
		public function set skeletonTimeScale(scale:Number):void
		{
			sklAnimator.playbackSpeed = scale;
		}
		
		public function get skeletonTimeScale():Number
		{
			return sklAnimator.playbackSpeed;
		}
		
		protected function onSklAnmComplete(e:AnimationStateEvent):void
		{
			dispatchEvent( new AnimationEvent(AnimationEvent.COMPLETE, skeletonAnm, e.animationNode.name) );			
		}
		
		protected function updateSkeletonAnimation():void
		{
			if (sklAnimator)
			{										
				stopSkeletonAnimation();
				
				sklAnimator.dispose();
				sklAnimator = null;
			}
			
			if (sklRefAnimator)
			{
				sklRefAnimator.dispose();
				sklRefAnimator = null;
			}
			
			if (skeletonRef)
			{
				sklRefAnimator = new SkeletonAnimatorProxy(skeletonRef.sklAnimator);
				
				mesh.animator = sklRefAnimator;
			}
			else if (skeleton && skeletonAnm && geometry && geometry.jointPerVertex > 0)
			{
				sklAnimator = new SkeletonAnimator(skeletonAnm.creatAnimationSet(geometry.jointPerVertex, skinGPU), skeleton.scope, !skinGPU);
				sklAnimator.autoUpdate = false;		
							
				SkeletonTools.poseFromSkeleton(sklAnimator.globalPose, skeleton.scope);
				
				mesh.animator = sklAnimator;	
				
				dispatchEvent( new Event(Event.ANIMATOR) );	
			}
			else
			{
				mesh.animator = null;
			}
		}
		
		public function get currentSkeletonAnimation():String
		{
			return sklAnimator.activeAnimationName;
		}
		
		public function get currentSkeletonWeight():Number
		{
			if (sklAnimator.activeState is CrossfadeTransitionState)
			{
				return CrossfadeTransitionState(sklAnimator.activeState).blendWeight;
			}
			
			return 1;
		}
		
		public function get currentSkeletonPosition():Number
		{
			var t:uint;
			var d:uint = SkeletonClipNode(sklAnimator.activeAnimation).totalDuration;
			
			if (sklAnimator.activeState is SkeletonClipState)
			{
				var clipState:SkeletonClipState = sklAnimator.activeState as SkeletonClipState;
				t = clipState.startTime + clipState.time;
			}
			else if (sklAnimator.activeState is CrossfadeTransitionState)
			{
				var crossFade:CrossfadeTransitionState = sklAnimator.activeState as CrossfadeTransitionState;
				t = crossFade.startTime + crossFade.time;
			}
									
			return t / d;
		}
		
		public function playingSkeletonAnimation():Boolean
		{
			return sklAnimator.activeAnimationName != null;
		}
		
		public function getJoint(jointName:String):Joint
		{
			joints ||= new Dictionary(true);
			
			if (!joints[jointName])
			{
				joints[jointName] = new Joint( sklAnimator, jointName );
			}
			
			return joints[jointName];
		}		
		
		//
		//	MORPHER
		//
		
		public function set morph(val:Morph):void
		{
			if (mph == val) return;
			mph = val;
			updateAnimation();
		}
		
		public function get morph():Morph
		{
			return mph;
		}
		
		public function setMorphWeightAt(index:Number, weight:Number):void
		{
			morpher.setWeightByIndex(index, weight);
		}
		
		public function setMorphWeight(name:String, weight:Number):void
		{
			morpher.setWeight(name, weight);
		}
		
		public function getMorphWeightAt(index:Number):Number
		{
			return morpher.getWeightByIndex(index);
		}
		
		public function getMorphWeight(name:String):Number
		{
			return morpher.getWeight(name);
		}
				
		protected function updateMorpher():void
		{
			if (morpher)
			{
				if (morpher is MorphGeometry)
					MorphGeometry(morpher).dispose();
				else if (mph is MorphAnimator)
					mesh.animator = null;
				
				morpher = null;
			}
			
			if (mph && geo && mph.numVertex == geo.numVertex)
			{
				if (!morphGPU || mesh.animator)
				{
					morpher = new MorphGeometry(mph.scope, geo.scope);
				}
				else
				{
					morpher = new MorphAnimator(new MorphAnimationSet(mph.scope.morphs, false));
					mesh.animator = morpher as MorphAnimator;
				}
			}
		}
			
		//
		//	MORPH ANIMATION
		//
		
		public function set morphAnimation(morphAnm:sunag.sea3d.framework.MorphAnimation):void
		{			
			if (this.morphAnm == morphAnm) return;
			this.morphAnm = morphAnm;
			updateAnimation();
		}
		
		public function get morphAnimation():sunag.sea3d.framework.MorphAnimation
		{
			return morphAnm;
		}
				
		public function playMorphAnimation(name:String, blendSpeed:Number=0, offset:Number=NaN):void
		{
			morphAnimator.play(name, blendSpeed, offset);	
			SEA3DGP.addAnimator(morphAnimator);
		}
		
		public function stopMorphAnimation():void
		{
			morphAnimator.stop();		
			SEA3DGP.removeAnimator(morphAnimator);
		}
		
		public function set morphAnimationBlendMode(blendMode:String):void
		{
			morphAnimator.blendMethod = AnimationBlendMode.BLEND_MODE[blendMode];
		}
		
		public function get morphAnimationBlendMode():String
		{
			return AnimationBlendMode.BLEND_MODE[morphAnimator.blendMethod];
		}
		
		public function set morphTimeScale(scale:Number):void
		{
			morphAnimator.timeScale = scale;
		}
		
		public function get morphTimeScale():Number
		{
			return morphAnimator.timeScale;
		}
		
		protected function updateMorphAnimation():void
		{
			if (morphAnimator)
			{
				stopMorphAnimation();
				
				morphAnimator = null;
			}
			
			if (morphAnm && morpher)
			{
				morphAnimator = new away3d.sea3d.animation.MorphAnimation(morphAnm.scope, morpher);
				morphAnimator.autoUpdate = false;
			}
		}
		
		//
		//	VERTEX ANIMATION
		//
		
		public function set vertexAnimation(val:VertexAnimation):void
		{			
			if (vertexAnm == val) return;
			vertexAnm = val;
			updateAnimation();
		}
		
		public function get vertexAnimation():VertexAnimation
		{
			return vertexAnm;
		}
		
		public function playVertexAnimation(name:String, blendSpeed:Number=0, offset:Number=NaN):void
		{
			vertexAnimator.play(name, new CrossfadeTransition(blendSpeed), offset);
			SEA3DGP.addAnimator(vertexAnimator);
		}
		
		public function stopVertexAnimation():void
		{
			SEA3DGP.removeAnimator(vertexAnimator);
		}
		
		public function set vertexTimeScale(scale:Number):void
		{
			vertexAnimator.playbackSpeed = scale;
		}
		
		public function get vertexTimeScale():Number
		{
			return vertexAnimator.playbackSpeed;
		}
		
		public function set vertexAnimationBlendMode(blendMode:String):void
		{
			TopLevel.warn('Unavailable: Mesh.setVertexAnimationBlendMode');
		}
		
		public function get vertexAnimationBlendMode():String
		{
			return AnimationBlendMode.LINEAR;
		}
		
		protected function updateVertexAnimation():void
		{
			if (vertexAnimator)
			{
				stopVertexAnimation();
				
				vertexAnimator.stop();
				vertexAnimator = null;
			}
			
			if (vertexAnm && geometry && geometry.numVertex == vertexAnm.numVertex && !mesh.animator)
			{
				vertexAnimator = new VertexAnimator( vertexAnm.createAnimationSet(geometry.scope) );
				vertexAnimator.autoUpdate = false;				
				
				mesh.animator = vertexAnimator;
			}						
		}
		
		//
		//	TOUCH
		//
		
		public function set touch(val:Boolean):void
		{
			mesh.mouseEnabled = val;					
		}
		
		public function get touch():Boolean
		{
			return mesh.mouseEnabled;
		}
		
		//
		//	ANIMATION
		//

		sea3dgp function updateAnimation():void
		{			
			updateSkeletonAnimation();
			updateVertexAnimation();
			updateMorpher();
			updateMorphAnimation();
		}
		
		//
		//	GEOMETRY
		//
				
		public function set offsetU(val:Number):void
		{
			for each(var g:SubMesh in mesh.subMeshes)			
				g.offsetU = val;			
		}
		
		public function get offsetU():Number
		{					
			return mesh.subMeshes[0].offsetU;			
		}
		
		public function set offsetV(val:Number):void
		{
			for each(var g:SubMesh in mesh.subMeshes)			
				g.offsetV = val;			
		}
		
		public function get offsetV():Number
		{					
			return mesh.subMeshes[0].offsetV;			
		}
		
		public function set scaleU(val:Number):void
		{
			for each(var g:SubMesh in mesh.subMeshes)			
				g.scaleU = val;			
		}
		
		public function get scaleU():Number
		{					
			return mesh.subMeshes[0].scaleU;			
		}
		
		public function set scaleV(val:Number):void
		{
			for each(var g:SubMesh in mesh.subMeshes)			
				g.scaleV = val;			
		}
		
		public function get scaleV():Number
		{					
			return mesh.subMeshes[0].scaleV;			
		}
		
		public function set uvRotation(val:Number):void
		{
			for each(var g:SubMesh in mesh.subMeshes)			
				g.uvRotation = val;			
		}
		
		public function get uvRotation():Number
		{					
			return mesh.subMeshes[0].uvRotation;			
		}
		
		public function set geometry(val:GeometryBase):void
		{
			if (geo == val) return;
			
			if ((geo = val))
			{
				mesh.geometry = geo.scope;
			}
			else mesh.geometry = GeometryBase.NULL;
			
			updateAnimation();
		}
		
		public function get geometry():GeometryBase
		{
			return geo;
		}
		
		//
		//	MATERIAL
		//
		
		public function set material(val:Material):void
		{
			if (multiMtl)
			{
				for each(var subMesh:SubMesh in mesh.subMeshes)
					subMesh.material = null;
					
				multiMtl = null;
			}
			
			mesh.material = (mtl = val) ? mtl.scope : null;
		}
		
		public function get material():Material
		{
			return mtl;
		}
		
		public function set multiMaterial(materials:Array):void
		{
			if (!multiMtl)
			{
				mtl = null;
				mesh.material = null;
			}
			
			multiMtl = materials;
			
			var subMeshes:Vector.<SubMesh> = mesh.subMeshes;
			for(var i:int = 0; i < subMeshes.length; i++)
			{
				subMeshes[i].material = materials[i] ? materials[i].scope : null;
			}						
		}
		
		public function get multiMaterial():Array
		{
			return mtl ? [mtl] : multiMtl;
		}		
		
		public function get numMaterial():uint
		{
			return multiMtl ? multiMtl.length : mtl ? 1 : 0;
		}
		
		public function set castShadow(val:Boolean):void
		{
			mesh.castsShadows = val;
		}
		
		public function get castShadow():Boolean
		{
			return mesh.castsShadows;
		}
		
		//
		//	HIERARCHY
		//
		
		override public function get min():Vector3D			
		{
			return mesh.bounds.min;
		}
		
		override public function get max():Vector3D			
		{
			return mesh.bounds.max;
		}
		
		//
		//	LOADER
		//
		
		override public function clone(force:Boolean=false):Asset			
		{
			var asset:sunag.sea3d.framework.Mesh = new sunag.sea3d.framework.Mesh();
			asset.copyFrom( this );
			return asset;
		}
		
		sea3dgp override function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var mesh:sunag.sea3d.framework.Mesh = asset as sunag.sea3d.framework.Mesh;
			
			mesh.skinGPU = skinGPU;
			
			geometry = mesh.geometry;
			
			if (mesh.numMaterial > 1) multiMaterial = mesh.multiMaterial;
			else material = mesh.material;
			
			castShadow = mesh.castShadow;
			
			skeleton = mesh.skeleton;
			skeletonAnimation = mesh.skeletonAnimation;
			skeletonReference = mesh.skeletonReference;
			morph = mesh.morph;
			morphAnimation = mesh.morphAnimation;		
			vertexAnimation = mesh.vertexAnimation;						
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	MESH
			//
			
			var mesh:SEAMesh = sea as SEAMesh;
			
			castShadow = mesh.castShadow;
			
			scope.transform = mesh.transform;
			
			geometry = mesh.geometry.tag;
			
			if (mesh.reference && mesh.reference.type == SEAMesh.REF_SKELETON_ANM)
			{
				skeletonReference = mesh.reference.ref.tag;
			}
			
			if (mesh.material)
			{
				if (mesh.material.length == 1)
				{
					material = mesh.material[0].tag;
				}
				else
				{
					var mats:Array = [];
					
					for each(var m:SEAMaterialBase in mesh.material)
					{
						mats.push( m.tag );
					}
					
					multiMaterial = mats;
				}
			}
			
			for each(var mod:SEAModifier in mesh.modifiers)
			{
				if (mod is SEASkeleton)
				{
					skeleton = mod.tag;
				}
				else if (mod is SEAMorph)
				{
					morph = mod.tag;
				}
			}
			
			for each(var anm:Object in mesh.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEASkeletonAnimation)
				{
					skeletonAnimation = SEASkeletonAnimation(tag).tag;
				}
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}