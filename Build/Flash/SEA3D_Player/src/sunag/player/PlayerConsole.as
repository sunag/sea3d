/* Copyright (c) 2013 Sunag Entertainment
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE. */

package sunag.player
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class PlayerConsole extends Sprite
	{
		private var _bg:Sprite = new Sprite();
		
		private var _width:int = 600;
		private var _height:int = 100;
		
		private var _field:TextField = new TextField();
		
		protected static const format:TextFormat = new TextFormat('Verdana',11,0xCCCCCC,null,null,null,null,null, TextFormatAlign.RIGHT);
		
		public function PlayerConsole()
		{
			var hover:Object = new Object();
			hover.fontWeight = "bold";
			hover.color = "#007DFF";
			
			var link:Object = new Object();
			link.fontWeight = "bold";
			link.textDecoration= "underline";
			link.color = "#CCCCCC";
			
			var active:Object = new Object();
			active.fontWeight = "bold";
			active.color = "#CCCCCC";
			
			var visited:Object = new Object();
			visited.fontWeight = "bold";
			visited.color = "#00CC7F";
			visited.textDecoration= "underline";
			
			var style:StyleSheet = new StyleSheet();
			style.setStyle("a:link", link);
			style.setStyle("a:hover", hover);
			style.setStyle("a:active", active);
			style.setStyle(".visited", visited);
						
			_field.defaultTextFormat = format;
			_field.styleSheet = style;			
			//_field.mouseEnabled = false;
			_field.selectable = false;
			
			_field.filters = [new GlowFilter(0, 1, 3, 3, 2, 1)];
			_field.addEventListener(TextEvent.LINK, onHyperLinkEvent);
			
			addChild(_bg);
			addChild(_field);
		}
		
		private function onHyperLinkEvent(e:TextEvent):void 
		{
			var str:String = _field.htmlText;
			str = str.split("'event:"+e.text+"'").join("'event:"+e.text+"' class='visited' ");
			_field.htmlText = str;						
			navigateToURL(new URLRequest(e.text), "_blank");
		}
		
		public function get textField():TextField
		{
			return _field;
		}
		
		public function get background():Sprite
		{
			return _bg;
		}
		
		public function update():void
		{
			_bg.graphics.clear();
			var m:Matrix = new Matrix;
			m.createGradientBox(_width, _height, Math.PI/2);
			_bg.graphics.beginGradientFill(GradientType.LINEAR, [0x101212,0x101212], [0.6,0.0],[0,255], m);
			_bg.graphics.drawRect(0, 0, _width, _height);
			_bg.graphics.endFill();
			
			_field.x = 2;
			_field.width = _width - 4;
			_field.height = _height + 20;
		}
		
		public override function set width(value:Number):void { _width = value; update(); }
		public override function get width():Number { return _width; }
		
		public override function set height(value:Number):void { _height = value; update(); }
		public override function get height():Number { return _height; }
	}
}