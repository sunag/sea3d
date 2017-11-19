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

package sunag.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.display.PixelSnapping;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import sunag.sea3d.objects.SEAJPEG;
	import sunag.sea3d.objects.SEAJPEGXR;
	
	public class BitmapUtils
	{ 
		public static function resize(source:BitmapData, target:BitmapData):void
		{
			var bitmap:Bitmap = new Bitmap(source, PixelSnapping.AUTO, true);
			
			var aspect:Number = source.width / source.height;
			var ratio:Number = target.width / target.height;
			
			var width:Number, height:Number;
			
			if (ratio < aspect)
			{
				width = target.height * ratio;
				height = target.height;
			}
			else
			{
				width = target.width;
				height = target.width / ratio;
			}
			
			bitmap.height = height;
			bitmap.width = width;
			
			target.drawWithQuality( bitmap, bitmap.transform.matrix, null, null, null, true, StageQuality.HIGH_8X8_LINEAR );
		}
		
		public static function powerOfTwoBitmapData(bitmapData:BitmapData, limit:uint=4096, box:Boolean=false):BitmapData
		{
			if (!MathHelper.isPowerOfTwo(bitmapData.width) || !MathHelper.isPowerOfTwo(bitmapData.height) ||				 				
				bitmapData.width > limit || bitmapData.height > limit || (box && bitmapData.width != bitmapData.height))
			{
				var bitmap:Bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO, true);
				
				var width:uint = MathHelper.nearestPowerOfTwo(bitmapData.width),
					height:uint = MathHelper.nearestPowerOfTwo(bitmapData.height);
				
				if (box)
				{
					width = height = Math.max(width, height);
				}
				
				if (width > limit) width = limit;
				if (height > limit) height = limit;
				
				bitmap.width = width;
				bitmap.height = height;
				
				var data:BitmapData = new BitmapData(width, height, bitmapData.transparent, 0);								
				data.drawWithQuality(bitmap, bitmap.transform.matrix, null, null, null, true, StageQuality.HIGH); 
				
				return data;
			}
			
			return bitmapData;
		}
		
		public static function fitScreen(source:BitmapData, target:BitmapData, preserveAspect:Boolean=true, center:Boolean=false):BitmapData
		{			
			var rect:Rectangle = source.getColorBoundsRect(0xFFFFFF, 0xFFFFFF, false);
			
			var aspectX:Number = 1,
				aspectY:Number = 1;
			
			if (preserveAspect)
			{
				if (rect.width > rect.height) aspectY = rect.height / rect.width;
				else aspectX = rect.width / rect.height;
			}
			
			if (rect.width < 32) rect.width = 32;
			if (rect.height < 32) rect.height = 32;
			
			var bmp2:BitmapData = new BitmapData(rect.width, rect.height, true, 0x00);
			bmp2.copyPixels(source, rect, new Point());
			
			var bitmap:Bitmap = new Bitmap(bmp2);
			
			if (preserveAspect)
			{
				bitmap.x = -(target.width/2) * (aspectX-1);
				bitmap.y = -(target.height/2) * (aspectY-1);
			}
			
			bitmap.width = target.width * aspectX;
			bitmap.height = target.height * aspectY;
			
			target.drawWithQuality(bmp2, bitmap.transform.matrix, null, null, null, true, StageQuality.HIGH_16X16);
			
			return target;
		}
		
		public static function encoder(bitmapData:BitmapData, format:String):ByteArray
		{
			var enc:Object;
			
			switch(format)
			{
				case SEAJPEG.TYPE:
					enc = new JPEGEncoderOptions(75);					
					break;
				
				case SEAJPEGXR.TYPE:
					enc = new JPEGEncoderOptions(75);					
					break;	
				
				default:
					enc = new PNGEncoderOptions(false);	
					break;
			}
			
			if (enc)
			{
				return bitmapData.encode(bitmapData.rect, enc);
			}
			
			return null;
		}			
	}
}