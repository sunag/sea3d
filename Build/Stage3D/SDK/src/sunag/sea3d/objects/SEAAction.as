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

package sunag.sea3d.objects
{
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	import sunag.utils.DataTable;
	
	use namespace sunag;
	
	public class SEAAction extends SEAObject
	{
		public static const TYPE:String = "act";
		
		public var action:Array = [];
				
		public static const SCENE:uint = 0;
		public static const ENVIRONMENT_COLOR:uint = 1;
		public static const ENVIRONMENT:uint = 2;		
		public static const FOG:uint = 3;
		public static const PLAY_ANIMATION:uint = 4;
		public static const PLAY_SOUND:uint = 5;
		public static const ANIMATION_AUDIO_SYNC:uint = 6;
		public static const LOOK_AT:uint = 7;		
		public static const RTT_TARGET:uint = 8;		
		public static const CAMERA:uint = 9;
		
		public function SEAAction(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		public override function load():void
		{
			var count:uint = data.readUnsignedInt();
			
			for(var i:uint = 0; i < count; i++)
			{								
				var flag:uint = data.readUnsignedByte();
				var kind:uint = data.readUnsignedShort();
								
				var size:uint = data.readUnsignedShort();
				var position:uint = data.position;
				
				var act:Object = action[i] = {kind:kind};
																				
				// range of animation
				if (flag & 1)
				{
					// start and count in frames
					act.range = [data.readUnsignedInt(), data.readUnsignedInt()];
				}
				
				// time
				if (flag & 2)
				{
					act.time = data.readUnsignedInt();
				}
				
				// easing
				if (flag & 4)
				{
					act.intrpl = DataTable.INTERPOLATION_TABLE[data.readUnsignedByte()];
															
					if (act.intrpl.indexOf('back.') == 0)
					{
						act.intrplParam0 = data.readFloat();					
					}
					else if (act.intrpl.indexOf('elastic.') == 0)					
					{
						act.intrplParam0 = data.readFloat();
						act.intrplParam1 = data.readFloat();
					}
				}								
				
				switch (kind)
				{
					case RTT_TARGET:
						act.source = sea.getSEAObject(data.readUnsignedInt());
						act.target = sea.getSEAObject(data.readUnsignedInt());
						break;
					
					case LOOK_AT:
						act.source = sea.getSEAObject(data.readUnsignedInt());
						act.target = sea.getSEAObject(data.readUnsignedInt());
						break;
					
					case PLAY_SOUND:					
						act.sound = sea.getSEAObject(data.readUnsignedInt());
						act.offset = data.readUnsignedInt();
						break;
					
					case PLAY_ANIMATION:
						act.object = sea.getSEAObject(data.readUnsignedInt());
						act.name = ByteArrayUtils.readUTFTiny(data);
						break;
					
					case FOG:						
						act.color = ByteArrayUtils.readUnsignedInt24(data);
						act.min = data.readFloat();
						act.max = data.readFloat();						
						break;
					
					case ENVIRONMENT:										
						act.texture = sea.getSEAObject(data.readUnsignedInt());
						break;
					
					case ENVIRONMENT_COLOR:
						act.color = ByteArrayUtils.readUnsignedInt24(data);
						break;	
					
					case CAMERA:
						act.camera = sea.getSEAObject(data.readUnsignedInt());
						break;	
					
					default:
						trace("Action \"" + type + "\" not found.");
						break;
				}
				
				data.position = position + size;
			}
		}		
	}
}