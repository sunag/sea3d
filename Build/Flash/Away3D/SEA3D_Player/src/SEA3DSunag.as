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

package
{
	import flash.net.URLRequest;

	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class SEA3DSunag extends SEA3DPlayer
	{
		public function SEA3DSunag()
		{
			isDebug = true;
			showWarning = true;
			
			// player.message = "Hello";
			// Upload visible
			//player.upload.visible = true;
			
			// Console - status
			//player.console.visible = false;
			
			// Load SEA3D from a URL or ByteArray. Example:
			//load(new URLRequest("myurl.sea"));
			//load(new MyFile());
			
			// Read external config (FlashVars - HTML Config) 
			readTokens(stage.loaderInfo.parameters);	
		}
		
		protected function readTokens(tokens:Object):void
		{
			for(var name:String in tokens)
			{
				var isTrue:Boolean = tokens[name] == "true";
				
				switch (name)
				{						
					case "load":
						load(new URLRequest(tokens[name]));
						break;
					
					case "forcecpu":
						forceCPU = isTrue;
						break;
					
					case "shadow":
						shadowMethod = tokens[name];
						break;
					
					case "fog":
						enabledFog = isTrue;
						break;
					
					case "player":
						player.visible = isTrue;
						break;		
					
					case "console":
						player.console.visible = isTrue;
						break;
					
					case "message":
						player.message = tokens[name];
						break;
					
					case "upload":
						player.upload.visible = isTrue;
						break;										
					
					case "autoPlay":
						autoPlay = isTrue;
						break;										
					
					case "cameraController":
						player.mode.visible = isTrue;
						break;	
					
					case "compactGeometry":
						compactGeometry = isTrue;
						break;
					
					case "camera":
						actualCamera = tokens[name];
						break;
					
					case "status":
						player.status = isTrue;
						break;
					
					case "dynamic":
						dynamicMode = isTrue;
						break;
					
					case "preset":
						setPreset(parseInt(tokens[name]));
						break;										
					
					case "debug":
						trace("Debug Mode");
						break;
					
					default:
						throw new Error(name + " not is valid parameter.");
						break;
				}
			}		
		}	
	}
}