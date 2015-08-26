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
	import flash.utils.ByteArray;
	
	import sunag.debugger.SEA3DPlayerDebugger;
	

	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class SEA3DDebugger extends SEA3DPlayer
	{
		public function SEA3DDebugger()
		{
			autoPlay = true;
						
			player.upload.visible = false;
			player.updatePanel();
			player.logo.getChildAt(0).y -= 150;
			player.logo.visible = false;			
			
			SEA3DPlayerDebugger.init(stage, 
				function(msg:String):void
				{
					unload();
				},
				function(data:ByteArray):void
				{
					loadBytes(data);
				});
		}
		
		override public function printError(msg:String):void
		{
			SEA3DPlayerDebugger.error(msg); 
		}
		
		override public function printWarn(msg:String):void
		{
			SEA3DPlayerDebugger.print( msg, 0xFF8800);
		}
	}
}