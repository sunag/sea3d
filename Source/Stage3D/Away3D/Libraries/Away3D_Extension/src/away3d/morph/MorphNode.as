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

package away3d.morph
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.events.EventDispatcher;
	
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;

	use namespace arcane;
	
	public class MorphNode extends EventDispatcher
	{
		arcane var _name:String;
		arcane var _vertex:Vector.<Number>;
		arcane var _normal:Vector.<Number>;
		arcane var _numVertices:uint;
		
		private var _initGPU:Boolean = false;
		
		// buffer dirty flags, per context:
		protected var _vertexBuffer : Vector.<VertexBuffer3D>;		
		protected var _vertexBufferContext : Vector.<Context3D>;
		protected var _verticesInvalid : Vector.<Boolean>;
		
		protected var _normalBuffer : Vector.<VertexBuffer3D>;		
		protected var _normalBufferContext : Vector.<Context3D>;
		protected var _normalInvalid : Vector.<Boolean>;
		
		public function MorphNode(name:String, vertex:Vector.<Number>, normal:Vector.<Number>=null)
		{
			_name = name;
			_vertex = vertex;
			_normal = normal;
			_numVertices = _vertex.length / 3;
		}
		
		public function updateVertex(vec : Vector.<Number>, weight : Number) : void
		{
			var i : int = 0, len : int = vec.length;
			
			while ( i < len )
				vec[i] += _vertex[i++] * weight;
		}
		
		public function updateVertexOffset(vec : Vector.<Number>, weight : Number) : void
		{
			const offset:int = 13;
			
			var i : int = 0, v:int, len : int = vec.length / offset;					
			
			for (; i < len; i++)
			{
				vec[i * offset] += _vertex[v++] * weight;
				vec[(i * offset) + 1] += _vertex[v++] * weight;
				vec[(i * offset) + 2] += _vertex[v++] * weight;
			}
		}
		
		public function updateNormal(vec : Vector.<Number>, weight : Number) : void
		{
			var i : int = 0, len : int = vec.length;
			
			while ( i < len )
				vec[i] += _normal[i++] * weight;
		}
		
		public function updateNormalOffset(vec : Vector.<Number>, weight : Number) : void
		{
			const offset:int = 13;
			
			var i : int = 0, v:int, len : int = vec.length / offset;					
			
			for (; i < len; i++)
			{
				vec[(i * offset) + 3] += _normal[v++] * weight;
				vec[(i * offset) + 4] += _normal[v++] * weight;
				vec[(i * offset) + 5] += _normal[v++] * weight;
			}
		}
		
		arcane function initGPU() : void
		{
			if (_initGPU) return;
			
			_vertexBuffer = new Vector.<VertexBuffer3D>(8);		
			_vertexBufferContext = new Vector.<Context3D>(8);
			_verticesInvalid = new Vector.<Boolean>(8, true);
			
			_normalBuffer = new Vector.<VertexBuffer3D>(8);		
			_normalBufferContext = new Vector.<Context3D>(8);
			_normalInvalid = new Vector.<Boolean>(8, true);
			
			_initGPU = true;
		}
		
		public function activateVertexBuffer(index : int, stage3DProxy : Stage3DProxy) : void
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			if (!_vertexBuffer[contextIndex] || _vertexBufferContext[contextIndex] != context) {
				_vertexBuffer[contextIndex] = context.createVertexBuffer(_numVertices, 3);
				_vertexBufferContext[contextIndex] = context;
				_verticesInvalid[contextIndex] = true;
			}
			if (_verticesInvalid[contextIndex]) {
				_vertexBuffer[contextIndex].uploadFromVector(_vertex, 0, _numVertices);
				_verticesInvalid[contextIndex] = false;
			}
			
			context.setVertexBufferAt(index, _vertexBuffer[contextIndex], 0, Context3DVertexBufferFormat.FLOAT_3);
		}
		
		public function activateNormalBuffer(index : int, stage3DProxy : Stage3DProxy) : void
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			if (!_normalBuffer[contextIndex] || _normalBufferContext[contextIndex] != context) {
				_normalBuffer[contextIndex] = context.createVertexBuffer(_numVertices, 3);
				_normalBufferContext[contextIndex] = context;
				_normalInvalid[contextIndex] = true;
			}
			if (_normalInvalid[contextIndex]) {
				_normalBuffer[contextIndex].uploadFromVector(_normal, 0, _numVertices);
				_normalInvalid[contextIndex] = false;
			}
			
			context.setVertexBufferAt(index, _normalBuffer[contextIndex], 0, Context3DVertexBufferFormat.FLOAT_3);
		}
				
		protected function invalidateBuffers(invalid : Vector.<Boolean>) : void
		{
			for (var i : int = 0; i < 8; ++i)
				invalid[i] = true;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function clone():MorphNode
		{
			return new MorphNode(_name, _vertex, _normal);
		}
	}
}