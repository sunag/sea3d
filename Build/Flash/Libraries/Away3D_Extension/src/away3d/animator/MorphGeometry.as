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
	import away3d.arcane;
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.morph.MorphNode;

	use namespace arcane;
	
	public class MorphGeometry implements IMorphAnimator
	{
		private var _animationSet:MorphAnimationSet
		private var _geometry:Geometry;
		
		private var _weights:Vector.<Number>;
		private var _weightsNames:Object = {};
		
		public function MorphGeometry(animationSet:MorphAnimationSet, geometry:Geometry)
		{
			_animationSet = animationSet;
			_geometry = geometry;
			
			_weights = new Vector.<Number>(_animationSet.numMorph);		
			
			updateIndexes();
		}
		
		public function get geometry():Geometry
		{
			return _geometry;
		}
		
		public function get animationSet():MorphAnimationSet
		{
			return _animationSet;
		}
		
		private function updateIndexes():void
		{
			var i:int = 0;
			
			_weightsNames = {};
			_weights.length = _animationSet.numMorph			
			
			for each(var n:MorphNode in _animationSet._morphs)			
				_weightsNames[ n._name ] = i++;	
		}
		
		public function setWeightByIndex(index:uint, value:Number):void
		{
			if (value == _weights[index]) return;
			
			var vertex:Vector.<Number>,		
				w:Number = value - _weights[index],
				useNormals:Boolean = _animationSet._useNormals;
			
			_weights[index] = value;
						
			var node:MorphNode = _animationSet._morphs[index];
			
			if (_geometry.subGeometries[0] is CompactSubGeometry)
			{	
				for each(var compGeo:CompactSubGeometry in _geometry.subGeometries)
				{
					node.updateVertexOffset(vertex = compGeo.vertexData, w);
					
					if (useNormals)
					{
						node.updateNormalOffset(vertex, w);
					}
					
					compGeo.updateData(vertex);					
				}
			}
			else
			{
				var subGeo:SubGeometry = _geometry.subGeometries[0] as SubGeometry;
				
				node.updateVertex(vertex = subGeo.vertexData, w);					
				subGeo.invalidateVertexData(vertex);
				
				if (useNormals)
				{
					node.updateNormal(vertex = subGeo.vertexNormalData, w);
					subGeo.invalidateVertexNormalData(vertex);
				}
			}					
		}
		
		public function containsMorph(name:String):Boolean
		{
			return _weightsNames[name] != undefined;
		}
		
		public function getWeightByIndex(index:uint):Number
		{
			return _weights[ index ];			
		}
		
		public function setWeight(name:String, value:Number):void
		{
			setWeightByIndex(_weightsNames[name], value);	
		}
		
		public function getWeight(name:String):Number
		{			
			return _weights[ _weightsNames[ name ] ];		
		}
		
		public function numMorph():uint
		{
			return _weights.length;
		}
		
		public function dispose():void
		{
			for(var i:int = 0; i < _weights.length; i++)
			{
				if (_weights[i] != 0)
				{
					setWeightByIndex(i, 0);
				}
			}
		}
	}
}