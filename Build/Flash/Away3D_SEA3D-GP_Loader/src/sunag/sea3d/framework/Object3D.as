package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	import flash.utils.setTimeout;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Matrix3DUtils;
	
	import sunag.sea3dgp;
	import sunag.animation.Animation;
	import sunag.sea3d.core.IGameObject;
	import sunag.sea3d.core.assets.ABC;
	import sunag.sea3d.core.script.Scripter;
	import sunag.sea3d.core.script.ScripterABC;
	import sunag.sea3d.events.Object3DEvent;
	import sunag.sea3d.objects.SEAABC;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAObject3D;
	
	use namespace sea3dgp;
	
	public class Object3D extends Asset implements IGameObject
	{				
		sea3dgp static const TYPE:String = 'Object3D/';
		
		sea3dgp var _parent:Object3D;
		
		sea3dgp var scope:ObjectContainer3D;	
		sea3dgp var scopeLocal:Object = {};
		sea3dgp var script:Vector.<Scripter> = new Vector.<Scripter>();
		sea3dgp var childrens:Array = [];
		
		sea3dgp var animationStd:sunag.sea3d.framework.AnimationStandard;
		sea3dgp var animator:sunag.animation.Animation;
		sea3dgp var animatorClass:Class;
		
		function Object3D(scope:ObjectContainer3D, animatorClass:Class=null)
		{
			this.scope = scope;
			this.animatorClass = animatorClass;
			
			scope.extra = this;
			
			super(TYPE);						
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene == scene) return;
			
			if (_scene)	
			{
				if (script.length > 0)
				{
					_scene.objects.splice( _scene.objects.indexOf( scene ), 1 );					
				}
				
				if (_parent == _scene) 
					_scene.remove( this );													
			}
			
			super.setScene( scene );
			
			if (scene)			
			{
				if (script.length > 0)
				{
					scene.objects.push( this );
				}
				
				if (!_parent) scene.add( this );										
			}
			
			for each(var child:Object3D in childrens)
			{
				child.setScene( scene );
			}						
		}
		
		//
		//	ANIMATION
		//
		
		public function set animation(animation:sunag.sea3d.framework.AnimationStandard):void
		{
			if (animator)
			{
				animator.stop();
				animator = null;
			}
			
			if (animatorClass && (animationStd = animation))
			{
				animator = new animatorClass(scope, animation.scope);
			}
		}
		
		public function get animation():sunag.sea3d.framework.AnimationStandard
		{
			return animationStd;
		}
		
		public function set relativeAnimation(val:Boolean):void
		{
			animator.relative = val;
		}
		
		public function get relativeAnimation():Boolean
		{
			return animator.relative;
		}
		
		public function playAnimation(name:String, blendSpeed:Number=0, offset:Number=NaN):void
		{
			animator.play(name, blendSpeed, offset);
		}
		
		public function stopAnimation():void
		{
			animator.stop();			
		}
		
		public function set timeScale(scale:Number):void
		{
			animator.timeScale = scale;
		}
		
		public function get timeScale():Number
		{
			return animator.timeScale;
		}
		
		public function set animationBlendMode(blendMode:String):void
		{
			animator.blendMethod = AnimationBlendMode.BLEND_MODE[blendMode];
		}
		
		public function get animationBlendMode():String
		{
			return AnimationBlendMode.BLEND_MODE[animator.blendMethod];
		}
		
		public function get currentAnimation():String
		{
			return animator.currentAnimation;
		}
		
		public function get playing():Boolean
		{
			return animator.playing;
		}

		//
		//	TRANSFORM
		//
		
		public function set x(val:Number):void
		{
			scope.x = val;
			dispatchTransform();
		}
		
		public function get x():Number
		{
			return scope.x;
		}
		
		public function set y(val:Number):void
		{
			scope.y = val;
			dispatchTransform();
		}
		
		public function get y():Number
		{
			return scope.y;
		}
		
		public function set z(val:Number):void
		{
			scope.z = val;
			dispatchTransform();
		}
		
		public function get z():Number
		{
			return scope.z;
		}
		
		public function set position(val:Vector3D):void
		{
			scope.position = val;			
			dispatchTransform();
		}
		
		public function get position():Vector3D
		{
			return scope.position;
		}
		
		public function set rotationX(val:Number):void
		{
			scope.rotationX = val;
			dispatchTransform();
		}
		
		public function get rotationX():Number
		{
			return scope.rotationX;
		}
		
		public function set rotationY(val:Number):void
		{
			scope.rotationY = val;
			dispatchTransform();
		}
		
		public function get rotationY():Number
		{
			return scope.rotationY;
		}
		
		public function set rotationZ(val:Number):void
		{
			scope.rotationZ = val;
			dispatchTransform();
		}
		
		public function get rotationZ():Number
		{
			return scope.rotationZ;
		}
		
		public function set rotation(val:Vector3D):void
		{
			scope.rotation = val;			
			dispatchTransform();
		}		
		
		public function get rotation():Vector3D
		{
			return scope.rotation;
		}
		
		public function set scaleX(val:Number):void
		{
			scope.scaleX = val;
			dispatchTransform();
		}
		
		public function get scaleX():Number
		{
			return scope.scaleX;
		}
		
		public function set scaleY(val:Number):void
		{
			scope.scaleY = val;
			dispatchTransform();
		}
		
		public function get scaleY():Number
		{
			return scope.scaleY;
		}
		
		public function set scaleZ(val:Number):void
		{
			scope.scaleZ = val;
			dispatchTransform();
		}
		
		public function get scaleZ():Number
		{
			return scope.scaleZ;
		}
		
		public function set scale(val:Vector3D):void
		{
			scope.scale = val;
			dispatchTransform();
		}
		
		public function get scale():Vector3D
		{			
			return scope.scale;
		}
		
		public function get globalPosition():Vector3D
		{
			return scope.scenePosition;
		}
		
		public function get frontVector():Vector3D
		{
			return Matrix3DUtils.getForward(scope.transform);
		}
		
		public function get rightVector():Vector3D
		{
			return Matrix3DUtils.getRight(scope.transform);
		}
		
		public function get upVector():Vector3D
		{
			return Matrix3DUtils.getUp(scope.transform);
		}
		
		public function get backVector():Vector3D
		{
			var director:Vector3D = Matrix3DUtils.getForward(scope.transform);
			director.negate();
			
			return director;
		}
		
		public function get leftVector():Vector3D
		{
			var director:Vector3D = Matrix3DUtils.getRight(scope.transform);
			director.negate();
			
			return director;
		}
		
		public function get downVector():Vector3D
		{
			var director:Vector3D = Matrix3DUtils.getUp(scope.transform);
			director.negate();
			
			return director;
		}
		
		public function lookAt(target:Vector3D, upAxis:Vector3D=null):void
		{
			scope.lookAt(target, upAxis);
			dispatchTransform();
		}
		
		public function translateLocal(axis:Vector3D, distance:Number):void
		{
			scope.translateLocal(axis, distance);
			dispatchTransform();
		}
		
		public function rotate(axis:Vector3D, angle:Number):void
		{
			scope.rotate(axis, angle);
			dispatchTransform();
		}
		
		sea3dgp function dispatchTransform():void
		{						
			dispatchEvent( new Object3DEvent( Object3DEvent.TRANSFORM ) );
		}
		
		//
		//	HIERARCHY
		//
		
		public function get parent():Object3D
		{
			return _parent;			
		}
		
		public function get local():Object
		{
			return scopeLocal;
		}
						
		public function add(child:Object3D):void
		{
			if (child._parent)
				child._parent.remove( child );
			
			child._parent = this;
			
			childrens.push( child );
			
			scope.addChild(child.scope);
			
			child.setScene( scene );
		}
		
		public function remove(child:Object3D):void
		{
			if (child._parent != this)
				throw new ReferenceError("Asset not found");
			
			child._parent = null;
			
			childrens.splice(childrens.indexOf( child ), 1);
			
			scope.removeChild(child.scope);
			
			child.setScene( null ); 
		}
		
		public function contains(child:Object3D):Boolean
		{
			return child._parent == this;
		}
		
		public function get children():Array
		{
			return childrens;
		}
		
		public function get min():Vector3D			
		{
			return new Vector3D(scope.minX, scope.minY, scope.minZ);
		}
		
		public function get max():Vector3D			
		{
			return new Vector3D(scope.maxX, scope.maxY, scope.maxZ);
		}
		
		//
		//	RENDER
		//
		
		public function set visible(val:Boolean):void
		{
			scope.visible = val;
		}
		
		public function get visible():Boolean
		{
			return scope.visible;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	OBJECT3D
			//
			
			var obj3d:SEAObject3D = sea as SEAObject3D;				
			
			if (obj3d.parent) 
				obj3d.parent.tag.add( this );
			
			for each(var anm:Object in obj3d.animations)
			{
				if (anm.tag.type == SEAAnimation.TYPE)
				{
					animation = SEAAnimation(anm.tag).tag; 
					relativeAnimation = anm.relative;
				}
			}
			
			for each(var src:Object in obj3d.scripts)
			{
				if (src.tag is SEAABC && src.method)
				{
					var abc:ScripterABC = new ScripterABC(src.tag.tag as ABC, this, src.method, src.params);
					
					script.push( abc );
					
					setTimeout(abc.run, 1);					
				}
			}
			
			for each(var tag:Object in obj3d.tags)
			{
				loadTag(tag);
			}
		}
		
		sea3dgp function loadTag(tag:Object):Boolean
		{
			switch(tag.kind)
			{
				case SEAObject3D.TAG_CHILDRENS:					
					for each(var o3d:SEAObject3D in tag.childrens)					
						add( o3d.tag );					
					return true;
			}
			
			return false;
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var obj3d:Object3D = asset as Object3D;
						
			animation = obj3d.animation;
			if (animation) relativeAnimation = obj3d.relativeAnimation;
			
			scope.transform = obj3d.scope.transform;
			
			for each(var child:Object3D in obj3d.childrens)
			{
				add( child.clone() as Object3D );					
			}
			
			for each(var src:Scripter in obj3d.script)
			{
				src = src.clone(this);
				
				script.push( src );
				
				setTimeout(src.run, 1);
			}
		}
		
		override public function dispose():void
		{						
			while (childrens.length)
				remove( childrens[0] );
			
			if (_parent)
				_parent.remove( this );
			
			scope.dispose();
			
			super.dispose();						
		}
	}
}