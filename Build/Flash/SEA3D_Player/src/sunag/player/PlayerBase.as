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
	import flash.display.Sprite;
	import flash.geom.Point;

	public class PlayerBase extends Sprite
	{			
		private var _playerTools:Sprite = new Sprite();
		
		private var _playButton:PlayButton = new PlayButton();
		private var _progressBar:ProgressBar = new ProgressBar();
		private var _fullScreenButton:FullScreenButton;
		private var _modeButton:ModeButton = new ModeButton();
		private var _marker:ProgressMarker = new ProgressMarker();
		private var _uploadButton:UploadButton = new UploadButton();
		private var _arButton:ARButton = new ARButton();
		private var _console:PlayerConsole = new PlayerConsole();
		private var _logo:SEA3DLogo = new SEA3DLogo();
		private var _offset:Point = new Point();		
		
		private var _width:int = 600;
		private var _height:int = 400;
		
		private var _duration:uint;
		
		public function PlayerBase()
		{				
			_fullScreenButton = new FullScreenButton(this);
			
			addChild(_logo);
			_logo.alpha = .3;
			
			// Tools
			addChild(_playerTools);			
			_playerTools.addChild(_playButton);
			_playerTools.addChild(_progressBar);
			_playerTools.addChild(_fullScreenButton);
			_playerTools.addChild(_modeButton);
			_playerTools.addChild(_marker);			
			
			// Utils
			addChild(_console);
			addChild(_uploadButton);
			addChild(_arButton);
					
			_progressBar.addEventListener(PlayerEvent.DRAGGING, onDragging);
			
			duration = 0;
			position = 0;
			
			update();
			updateProgress();
			
			buttonMode = true;
		}			
		
		public function get playerTools():Sprite
		{
			return _playerTools;
		}
		
		override public function set buttonMode(value:Boolean):void
		{
			_playButton.buttonMode = 
				_uploadButton.buttonMode = 
				_arButton.buttonMode =
				_fullScreenButton.buttonMode =
				_modeButton.buttonMode = true;
		}
		
		override public function get buttonMode():Boolean
		{
			return _playButton.buttonMode;
		}
		
		protected function onDragging(e:PlayerEvent):void
		{			
			updateProgress();
		}
		
		public function set state(value:String):void
		{						
			if (value == PlayerState.PLAYING)
			{
				_playButton.state = PlayButton.PAUSE;
			}
			else if (value == PlayerState.PAUSED)
			{
				_playButton.state = PlayButton.PLAY;
			}
		}
		
		public function get state():String
		{
			if (_progressBar.dragging)
			{
				return PlayerState.DRAGGING;
			}			
			else if (_playButton.state == PlayButton.PLAY)
			{
				return PlayerState.PAUSED;
			}
			else
			{
				return PlayerState.PLAYING;
			}
		}
		
		public function set htmlText(value:String):void
		{
			_console.textField.htmlText = value;
		}
		
		public function get htmlText():String
		{
			return _console.textField.htmlText;
		}		
		
		public function set text(value:String):void
		{
			_console.textField.text = value;
		}
		
		public function get text():String
		{
			return _console.textField.text;
		}
		
		public function get console():PlayerConsole
		{
			return _console;
		}
		
		public function get play():PlayButton
		{
			return _playButton;
		}
		
		public function get progressBar():ProgressBar
		{
			return _progressBar;
		}
		
		public function get ar():ARButton
		{
			return _arButton;
		}
		
		public function get fullScreen():FullScreenButton
		{
			return _fullScreenButton;
		}
		
		public function get mode():ModeButton
		{
			return _modeButton;
		}
		
		public function get marker():ProgressMarker
		{
			return _marker;
		}
		
		public function get logo():SEA3DLogo
		{
			return _logo;
		}
		
		public function get upload():UploadButton
		{
			return _uploadButton;
		}
		
		public function get progress():Number
		{
			return _progressBar.progress;
		}
		
		public function set progress(value:Number):void
		{
			_progressBar.progress = value;	
		}
		
		public function set duration(value:uint):void
		{
			_duration = value;			
			markerVisible = _duration > 0;			
			updateProgress();
		}
		
		public function get duration():uint
		{
			return _duration;
		}
		
		public function set position(value:Number):void
		{
			_progressBar.position = value;
			updateMarker();
			updateProgress();
		}
		
		public function get position():Number
		{
			return _progressBar.position;
		}
		
		public function set offset(value:Point):void
		{
			_offset = value;
		}
		
		public function get offset():Point
		{
			return _offset;
		}
		
		public function update():void
		{
			updateMarker();
		}
		
		public function updatePanel():void
		{
			_logo.x = (_width/2) - (_logo.width/2);
			_logo.y = (_height/2) - (_logo.height/2);
			
			_console.width = _width;				 
			_console.height = _uploadButton.height + 120;
			
			if (_uploadButton.visible)
			{
				_uploadButton.x = 20 + _offset.x;
				_arButton.x = _uploadButton.x + _uploadButton.width + 20;
			}
			else
			{
				_uploadButton.x = 0;
				_arButton.x = 20 + _offset.x;
			}
			
			_uploadButton.y = 20 + _offset.y;			
			_arButton.y = _uploadButton.y;
			
			_playerTools.y = _height - (_playButton.height + 40);
			
			// draw bg
			_playerTools.graphics.clear();
			_playerTools.graphics.beginFill(0x101212, .4);
			_playerTools.graphics.drawRect(0,0,_width,_height - _playerTools.y);
			
			_playButton.x = 20;
			_playButton.y = 20;
			
			_progressBar.x = _playButton.x + _playButton.width + 20;
			_progressBar.y = Math.round((_playButton.height / 2) - (_progressBar.height/2)) + 20;
			
			if (_fullScreenButton.visible)
			{				
				var fullScreenX:int = _width - (_fullScreenButton.width + 20);
				_fullScreenButton.y = Math.round((_playButton.height / 2) - (_fullScreenButton.height/2)) + 20;
							
				if (_modeButton.visible)
				{
					_modeButton.x = fullScreenX;
					_modeButton.y = _fullScreenButton.y;
					
					_fullScreenButton.x = (fullScreenX - 20) - _modeButton.width;
				}
				else
				{
					_fullScreenButton.x = fullScreenX;
				}
				
				_progressBar.width = _fullScreenButton.x - (_progressBar.x + 20);
			}
			else
			{
				_progressBar.width = _width - (_progressBar.x + 20);
			}
		}
		
		public function set markerVisible(value:Boolean):void
		{
			_progressBar.mouseChildren =
				_playButton.mouseChildren =
				_progressBar.mouseEnabled =
				_playButton.mouseEnabled = value ;			
			
			_playButton.alpha = value ? 1 : .6;
			
			_marker.visible = value;
			
			_logo.visible = !value;
		}
		
		public function get markerVisible():Boolean
		{
			return _marker.visible;
		}
		
		private function updateMarker():void
		{
			_marker.x = _progressBar.x + Math.round(_progressBar.position * _progressBar.width);
			_marker.y = _progressBar.y;
		}
		
		private function updateProgress():void
		{
			var tip:Array = [];
			
			var durationMs:Number = _duration;
			var positionMs:Number = int(_progressBar.position * _duration);
			
			if (durationMs > 1000)
			{
				tip[0] = String(positionMs / 1000);
				tip[1] = String(durationMs / 1000);
			}
			else
			{
				tip[0] = String(positionMs);
				tip[1] = String(durationMs);
			}
			
			if (state == PlayerState.PLAYING)
			{				
				for (var i:int=0;i<tip.length;i++)
				{
					var str:String = tip[i];
					var index:int = str.indexOf(".");
					
					if (index == -1)
					{						
						str += ".";
						index = str.length;
					}
					else ++index;
					
					str += getZString(3-(str.length-index));
					
					tip[i] = str.substring(0,index+3);
				}
				
			}
					
			_marker.htmlText = tip.join("/");
		}
		
		private function getZString(count:int):String
		{
			var str:String = "";
			for(var i:int=0;i<count;i++)
				str += "0"
			return str;
		}
		
		public override function set width(value:Number):void { _width = value; updatePanel(); }
		public override function get width():Number { return _width; }
		
		public override function set height(value:Number):void { _height = value; updatePanel(); }
		public override function get height():Number { return _height; }
	}
}