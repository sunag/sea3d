/*
*
* Copyright (c) 2015 Sunag Entertainment
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
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.sea3d.physics.WheelData;
	
	public class SEACarController extends SEARigidBody
	{
		public static const TYPE:String = "carc";
		
		public var suspensionStiffness : Number;
		public var suspensionCompression : Number;
		public var suspensionDamping : Number;
		public var maxSuspensionTravelCm : Number;
		public var frictionSlip : Number;
		public var maxSuspensionForce : Number;
		public var dampingCompression : Number;
		public var dampingRelaxation : Number;
		
		public var wheel:Vector.<WheelData>;
		
		public function SEACarController(name:String, sea:SEA)
		{
			super(name, sea, TYPE);						
		}				
		
		override protected function read(data:ByteArray):void
		{
			super.read(data);
			
			suspensionStiffness = data.readFloat();
			suspensionCompression = data.readFloat();
			suspensionDamping = data.readFloat();
			maxSuspensionTravelCm = data.readFloat();
			frictionSlip = data.readFloat();
			maxSuspensionForce = data.readFloat();
			
			dampingCompression = data.readFloat();
			dampingRelaxation = data.readFloat();
			
			wheel = new Vector.<WheelData>(data.readUnsignedByte());	
			
			for(var i:int = 0; i < wheel.length; i++)
			{
				wheel[i] = new WheelData(data, sea);	
			}					
		}
	}
}