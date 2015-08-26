/*
*
* Copyright (c) 2013 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

package away3d.animator
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.events.Event;
	
	import away3d.arcane;
	import away3d.animators.AnimatorBase;
	import away3d.animators.IAnimator;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.base.ISubGeometry;
	import away3d.core.base.SubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.morph.MorphNode;

	use namespace arcane;

	public class MorphAnimator extends AnimatorBase implements IAnimator, IMorphAnimator
	{	
		private static var WeightsBuffer:Vector.<Number> = new Vector.<Number>(4, true);
		
		private var _weights:Vector.<Number>;
		private var _weightsMods:Object = {};
		private var _weightsNames:Object = {};
		private var _morphAnimationSet:MorphAnimationSet;
		private var _usesCPU:Boolean;
		
		private var _vertexBase : Vector.<Number>;
		private var _vertexNormalBase : Vector.<Number>;
		
		public function MorphAnimator(animationSet:MorphAnimationSet)
		{
			super(_morphAnimationSet=animationSet);
			
			_usesCPU = _morphAnimationSet._usesCPU;
			_weights = new Vector.<Number>(_morphAnimationSet.numMorph);
			
			_morphAnimationSet.addEventListener(Event.CHANGE, onMorphChange, false, 0, true);
			
			updateIndexes();
		}
				
		public function clone():IAnimator
		{
			return new MorphAnimator(_morphAnimationSet);
		}
		
		private function onMorphChange(e:Event):void
		{
			if (_morphAnimationSet.action == MorphAnimationSet.ADD)
			{
				_weights.length = _morphAnimationSet._morphs.length;
				
				var index:int = _weights.length - 1;
				var n:MorphNode = _morphAnimationSet._morphs[index];		
					
				_weightsNames[ index ] = n._name;
				_weightsNames[ n._name ] = index;
			}
			else updateIndexes();
		}
				
		private function updateIndexes():void
		{
			var i:int, name:String	
			var cMods:Object = _weightsMods;
			var cNames:Object = _weightsNames;			
						
			i = 0;
			while (i < _weights.length)	
				cMods[i] = _weights[i++];		
			
			_weightsMods = {};
			_weightsNames = {};
			
			// clear and update
			_weights.length = 0;
			_weights.length = _morphAnimationSet._morphs.length;			
			
			i = 0;
			for each(var n:MorphNode in _morphAnimationSet._morphs)	
			{
				_weightsNames[ i ] = n._name;
				_weightsNames[ n._name ] = i++;	
			}
			
			for (var index in cMods)
			{
				name = cNames[index];
				
				if (_weightsNames[name] != null)
				{
					_weights[ _weightsNames[name] ] = cMods[ index ];
				}
			}
		}
		
		public function setWeightByIndex(index:uint, value:Number):void
		{
			if (_usesCPU) _weightsMods[ index ]  = value;
			else if (value != 0) _weightsMods[ index ]  = value;
			else delete _weightsMods[ index ];	
		}
		
		public function containsMorph(name:String):Boolean
		{
			return _weightsNames[name] != undefined;
		}
		
		public function getWeightByIndex(index:uint):Number
		{
			return _weightsMods[ index ] || _weights[ index ];			
		}
		
		public function setWeight(name:String, value:Number):void
		{
			if (_usesCPU) _weightsMods[ _weightsNames[name] ]  = value;
			else if (value != 0) _weightsMods[ _weightsNames[name] ]  = value;
			else delete _weightsMods[ _weightsNames[name] ];	
		}
		
		public function getWeight(name:String):Number
		{			
			var index:uint = _weightsNames[ name ];
			return _weightsMods[ index ] || _weights[ index ];		
		}
		
		public function numMorph():uint
		{
			return _weights.length;
		}
		
		public function setRenderState(stage3DProxy : Stage3DProxy, renderable : IRenderable, vertexConstantOffset : int, vertexStreamOffset : int, camera:Camera3D) : void
		{
			var index, // empty
				node:MorphNode,
				morphs:Vector.<MorphNode> = _morphAnimationSet._morphs,
				useNormals:Boolean = _morphAnimationSet._useNormals,
				vertex:Vector.<Number>, normals:Vector.<Number>;
			
			if (_usesCPU)
			{				
				var subGeo : SubGeometry = (renderable as SubMesh).subGeometry as SubGeometry;			
				var subGeos:Vector.<ISubGeometry> = subGeo.parentGeometry.subGeometries;
				
				for (index in _weightsMods)
				{
					var w:Number = _weightsMods[ index ] - _weights[index];
					
					_weights[index] = _weightsMods[index];
					
					node = morphs[index];	
					
					node.updateVertex(vertex = subGeo.vertexData, w);	
					
					if (useNormals)
						node.updateNormal(normals = subGeo.vertexNormalData, w);
					
					for each (var geo:SubGeometry in subGeos)
					{			
						geo.invalidateVertexData(vertex);
						
						if (useNormals)
							geo.invalidateVertexNormalData(normals);						
					}
					
					delete _weightsMods[index];
				}
				
				return;
			}
						
			var streamIndex:int = _morphAnimationSet._streamIndex;			
			
			var count:int = streamIndex, 
				countBuffer:int = 0,
				context:Context3D = stage3DProxy._context3D;
			
			for (index in _weightsMods)
			{
				if (countBuffer == MorphAnimationSet.GPULimit) break;
				
				node = morphs[index];			
				
				WeightsBuffer[countBuffer++] = _weights[index] = _weightsMods[index];
				
				node.activateVertexBuffer(count++, stage3DProxy);
				
				if (useNormals)
					node.activateNormalBuffer(count++, stage3DProxy);
			}
			
			while (countBuffer < MorphAnimationSet.GPULimit)
			{
				WeightsBuffer[countBuffer++] = 0;
				
				renderable.activateVertexBuffer(count++, stage3DProxy);
				
				if (useNormals)
					renderable.activateVertexNormalBuffer(count++, stage3DProxy);
			}
						
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vertexConstantOffset, WeightsBuffer, 1);
		}
		
				
		public function testGPUCompatibility(pass : MaterialPassBase) : void
		{			
		}
	}
}