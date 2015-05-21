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

package sunag.sea3d.player
{
	import flash.net.FileFilter;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import sunag.animation.AnimationPlayer;
	import sunag.player.PlayButton;
	import sunag.player.PlayerBase;
	import sunag.player.PlayerState;
	import sunag.utils.AverageTimeStep;
	
	public class Player extends PlayerBase
	{
		private var _target:AnimationPlayer;		
		private var _interval:uint = getTimer();
		private var _timeStep:AverageTimeStep = new AverageTimeStep();
		private var _error:String;
		private var _camera:String;
		private var _tips:String;
		private var _message:String;
		private var _title:String;
		private var _status:Boolean = true;
		
		public function Player()
		{
			super();
			upload.fileFilter = [new FileFilter("Sunag Entertainment Assets (*.sea)","*.sea")];
		}
				
		public function set target(value:AnimationPlayer):void
		{
			_target = value;						
			play.state = PlayButton.PLAY;			
			
			if (_target)
			{
				duration = value.duration;
				position = 0;
			}
			else
			{
				duration = 0;
				position = 0;
			}
			
			logo.visible = _target == null;
			
			update();
		}
				
		public function get target():AnimationPlayer
		{
			return _target;
		}
		
		public function set camera(value:String):void
		{
			_camera = value;
			updateConsole();
		}
		
		public function get camera():String
		{
			return _camera;
		}
		
		public function set error(value:String):void
		{
			_error = value;		
			updateConsole();
		}
		
		public function get error():String
		{
			return _error;
		}
		
		public function set message(value:String):void
		{
			_message = value;		
			updateConsole();
		}
		
		public function get message():String
		{
			return _message;
		}
		
		public function set tips(value:String):void
		{
			_tips = value;		
			updateConsole();
		}
		
		public function get tips():String
		{
			return _tips;
		}
		
		public function set status(value:Boolean):void
		{
			_status = value;
			updateConsole();
		}
		
		public function get status():Boolean
		{
			return _status;
		}
		
		public function set title(value:String):void			
		{
			_title = value;
			updateConsole();
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function updateConsole():void
		{
			var stringBuilder:Array = [];
			
			if (_title)
			{
				stringBuilder.push(_title);//"SEA3D Player 1.3\n© Sunag Entertainment\n"
			}
			
			if (_status)
			{
				stringBuilder.push('<b>FPS:</b> ' + Math.round(_timeStep.averageFrameRate));
				stringBuilder.push('<b>Memory:</b> ' + compactNumberString(((System.privateMemory)/1024)/1024) + "MB\n");
				
				if (_camera) stringBuilder.push('<b><font color="#00FF99">Camera:</font></b> ' + _camera + "\n");
				if (_error) stringBuilder.push('<b><font color="#FF9900">Error:</font></b> ' + _error);			
				if (_tips) stringBuilder.push('<b><font color="#0099FF">Tips:</font></b> ' + _tips);
			}												
			
			if (_message) stringBuilder.push('<b>' + _message + '</b>');
			
			htmlText = stringBuilder.join("\n");
		}
				
		public override function update():void
		{
			if (stage) _timeStep.fixedFrameRate = stage.frameRate;
			
			if (getTimer() - _interval > 500)
			{
				updateConsole();
				
				_interval = getTimer();
			}							
			
			if (_target)
			{
				switch(state)
				{					
					case PlayerState.DRAGGING:
						_target.position = position;
						_target.updateTime(_target.time, getTimer());						
						break
					
					case PlayerState.PLAYING:
						_target.update(getTimer());
						position = _target.position;						
						break;
					
					case PlayerState.PAUSED:
						position = _target.position;
						_target.updateTime(_target.time, getTimer(), false);
						break;					
				}			
			}						
			
			super.update();
		}
		
		private function compactNumberString(value:Number):String
		{
			var str:String = value.toString();
			var index:int = str.indexOf('.');
			
			if (index > 0)
			{
				str = str.substr(0, index+2);
			}
			else
			{
				str += ".0";
			}
			
			return str;
		}
	}
}