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

package away3d.materials.methods
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import away3d.textures.Texture2DBase;

	public class LayeredTexture extends EventDispatcher
	{
		public static const NORMAL:String = "normal";
		public static const ADD:String = "add";
		public static const SUBTRACT:String = "subtract";
		public static const MULTIPLY:String = "multiply";
		public static const DIVIDE:String = "dividing";
		public static const DARKEN:String = "darken";
		public static const LIGHTEN:String = "lighten";
		public static const COLORBURN:String = "colorburn";
		public static const LINEARBURN:String = "linearburn";
		public static const SCREEN:String = "screen";
		public static const COLORDODGE:String = "colordodge";
		public static const LINEARLIGHT:String = "linearlight";
		public static const SOFTLIGHT:String = "softlight";
		public static const OVERLAY:String = "overlay";
		public static const HARDLIGHT:String = "hardlight";
		public static const HARDMIX:String = "hardmix";
		public static const AVERAGE:String = "average";
		public static const REFLECT:String = "reflect";
		public static const GLOW:String = "glow";
		public static const NEGATION:String = "negation";
		public static const GRAINEXTRACT:String = "grainextract";
		public static const EXCLUSION:String = "exclusion";
		public static const PHOENIX:String = "phoenix";
		public static const LIGHTERCOLOR:String = "lightercolor";
		public static const DARKERCOLOR:String = "darkercolor";
		public static const DIFERENCE:String = "difference";
		
		protected var _blendMode:String = "normal";
		protected var _scaleU:Number = 1;
		protected var _scaleV:Number = 1;
		protected var _offsetU:Number = 0;
		protected var _offsetV:Number = 0;
		protected var _alpha:Number = 1;
		protected var _repeat:Boolean = true;
		protected var _texture:Texture2DBase;
		protected var _mask:Texture2DBase;
		protected var _textureChannel:uint = 0;
		protected var _maskChannel:uint = 0;
		
		public function LayeredTexture(texture:Texture2DBase=null, mask:Texture2DBase=null)
		{
			_texture = texture;
			_mask = mask;
		}
		
		public function set textureUVChannel(value:uint):void 
		{ 
			if (_textureChannel == value) return;
			_textureChannel = value; 
			dispatchChange(); 
		}
		
		public function get textureUVChannel():uint { return _textureChannel; }
		
		public function set maskUVChannel(value:uint):void 
		{
			if (_maskChannel == value) return;
			_maskChannel = value; 
			dispatchChange(); 
		}
		
		public function get maskUVChannel():uint { return _maskChannel; }
		
		public function set alpha(value:Number):void { _alpha = value; }
		public function get alpha():Number { return _alpha; }
		
		public function set offsetU(value:Number):void { _offsetU = value; }
		public function get offsetU():Number { return _offsetU; }
		
		public function set offsetV(value:Number):void { _offsetV = value; }
		public function get offsetV():Number { return _offsetV; }
		
		public function set scaleU(value:Number):void { _scaleU = value; }
		public function get scaleU():Number { return _scaleU; }
		
		public function set scaleV(value:Number):void { _scaleV = value; }
		public function get scaleV():Number { return _scaleV; }
		
		public function set blendMode(value:String):void 
		{ 
			if (_blendMode == value) return;
			_blendMode = value; 
			dispatchChange();
		}
		
		public function get blendMode():String { return _blendMode; }		
		
		public function set repeat(value:Boolean):void 
		{ 
			if (_repeat == value) return;
			_repeat = value; 
			dispatchChange();
		}
		public function get repeat():Boolean { return _repeat; }
		
		public function set texture(value:Texture2DBase):void 
		{ 
			if (_texture == value) return;
			_texture = value;
			dispatchChange();
		}
		
		public function get texture():Texture2DBase { return _texture; }		
		
		public function set mask(value:Texture2DBase):void 
		{ 
			if (_mask == value) return;
			_mask = value; 
			dispatchChange();
		}
		
		public function get mask():Texture2DBase { return _mask; }
		
		protected function dispatchChange() : void
		{
			if (hasEventListener(Event.CHANGE))
				dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function clone():LayeredTexture
		{
			var layer:LayeredTexture = new LayeredTexture(_texture, _mask);
			layer._textureChannel = _textureChannel;
			layer._maskChannel = _maskChannel;
			layer._blendMode = _blendMode;
			layer._scaleU = _scaleU;
			layer._scaleV = _scaleV;
			layer._offsetU = _offsetU;
			layer._offsetV = _offsetV;
			layer._alpha = _alpha;
			layer._repeat = _repeat;
			return layer;
			
		}
	}
}