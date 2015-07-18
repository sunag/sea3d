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
	import away3d.animators.AnimationSetBase;
	import away3d.animators.IAnimationSet;
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.morph.MorphNode;
	
	import flash.display3D.Context3D;
	import flash.events.Event;

	use namespace arcane;
	
	public class MorphAnimationSet extends AnimationSetBase implements IAnimationSet
	{
		arcane static const GPULimit:uint = 2;
		
		arcane static const ADD:int = 1;
		arcane static const UNKNOWN:int = 0;
		
		arcane var _morphs:Vector.<MorphNode>;				
		
		arcane var _streamIndex:int;		
		
		arcane var _len:int = 0;		
		arcane var _useNormals:Boolean;
		arcane var _useTangents : Boolean;		
		arcane var _usesCPU:Boolean = false;
		
		arcane var action:int = UNKNOWN;
		
		public function MorphAnimationSet(morphs:Vector.<MorphNode>, usesCPU:Boolean=false)
		{
			_morphs = morphs || new Vector.<MorphNode>();
			_usesCPU = usesCPU;
			
			if (!_usesCPU)
			{
				for each(var node:MorphNode in _morphs)
					node.initGPU();
			}
			else if (_morphs.length > 0)
			{
				_useNormals = _morphs[0]._normal != null;				
			}
		}
		
		override public function get usesCPU():Boolean
		{
			return _usesCPU;
		}
		
		public function activate(stage3DProxy : Stage3DProxy, pass : MaterialPassBase) : void
		{
		}
		
		public function deactivate(stage3DProxy:Stage3DProxy, pass:MaterialPassBase):void
		{			
			if (_usesCPU)
				return;
			
			var context : Context3D = stage3DProxy._context3D;			
			var i:int = 0, count:int = _streamIndex;
			
			while (i++ < GPULimit)
			{				
				context.setVertexBufferAt(count++, null);
				
				if (_useNormals)
					context.setVertexBufferAt(count++, null);								
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function getAGALFragmentCode(pass : MaterialPassBase, shadedTarget : String, profile:String) : String
		{
			return "";
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALUVCode(pass : MaterialPassBase, UVSource : String, UVTarget:String) : String
		{
			return "mov " + UVTarget + "," + UVSource + "\n";
		}
		
		/**
		 * @inheritDoc
		 */
		public function doneAGALCode(pass : MaterialPassBase):void
		{
			
		}
		
		public function getAGALVertexCode(pass : MaterialPassBase, sourceRegisters : Vector.<String>, targetRegisters : Vector.<String>, profile:String) : String
		{
			var i:int, j:int;
			var code:String = "";	
			
			for(i=0;i<sourceRegisters.length;i++)
				code += "mov " + targetRegisters[i] + ", " + sourceRegisters[i] + "\n";
			
			if (_usesCPU)							
				return code;
						
			_len = sourceRegisters.length;
			_streamIndex = pass.numUsedStreams;
						
			_useNormals = _len > 1;
			_useTangents = _len > 2;
			
			var regs : Array = ["x", "y", "z", "w"];
			
			var temp1 : String = findTempReg(targetRegisters);
			
			var count:int = _streamIndex;
			
			for (i = 0; i < GPULimit; i++)
			{
				for (j = 0; j < _len; j++)
				{					
					var target:String = targetRegisters[j];
					//var vertexBase:String = sourceRegisters[j];
					
					var vertexMorph:String = "va" + count++;
					var weightMorph:String = "vc" + pass.numUsedVertexConstants + "." + regs[i];
					
					// difference format
					//code += "sub " + temp1 + ", " + vertexMorph + ", " + vertexBase + "\n";
					//code += "mul " + temp1 + ", " + temp1 + ", " + weightMorph + "\n";
					
					// aditive format - SEA3D Format
					code += "mul " + temp1 + ".x, " + vertexMorph + ".x, " + weightMorph + "\n";
					code += "mul " + temp1 + ".y, " + vertexMorph + ".y, " + weightMorph + "\n";
					code += "mul " + temp1 + ".z, " + vertexMorph + ".z, " + weightMorph + "\n";
					
					// result
					code += "add " + target + ".xyz, " + target + ".xyz, " + temp1 + ".xyz\n";	
				}
			}						
			
			return code;
		}
		
		public function addMorph(mod:MorphNode) : void
		{
			_morphs.push(mod);
			if (!_usesCPU) mod.initGPU();
			invalidateState(ADD);
		}
		
		public function getMorph(index:int) : MorphNode
		{
			return _morphs[index];
		}
		
		public function getMorphIndex(mod:MorphNode) : int
		{
			return _morphs.indexOf(mod);
		}
		
		public function getMorphByName(name:String) : MorphNode
		{
			for each (var mod:MorphNode in _morphs)
			{
				if (mod._name == name)
					return mod;
			}
			
			return null;
		}
		
		public function addMorphAt(mod:MorphNode, index:int) : void
		{
			_morphs.splice(index, 0, mod);
			if (!_usesCPU) mod.initGPU();
			invalidateState();
		}
		
		public function removeMorph(mod:MorphNode) : void
		{
			_morphs.splice(_morphs.indexOf(mod), 1);
			invalidateState();
		}
		
		public function removeMorphAt(index:int) : void
		{
			_morphs.splice(index, 1);
			invalidateState();
		}
		
		public function get numMorph() : int
		{
			return _morphs.length;
		}
		
		public function get morphs():Vector.<MorphNode>
		{
			return _morphs;
		}
		
		/**
		 * Invalidates the state, so it needs to be updated next time it is requested.
		 */
		public function invalidateState(act:int=UNKNOWN) : void
		{
			action = act;
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}