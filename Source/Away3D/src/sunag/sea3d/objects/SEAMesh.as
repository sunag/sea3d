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
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	use namespace sunag;
	
	public class SEAMesh extends SEAEntity3D
	{
		public static const TYPE:String = "m3d";				
		
		public static const REF_SKELETON_ANM:int = 0;
		
		public var transform:Matrix3D;	
		public var reference:Object;
		
		public var geometry:SEAObject;//SEAGeometryBase
		public var material:Vector.<SEAObject>;//SEAMaterialBase
		public var modifiers:Vector.<SEAObject>;//SEAModifier											
		
		public var min:Vector3D;
		public var max:Vector3D;
		
		public function SEAMesh(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}			
		
		protected override function read(data:ByteArray):void
		{
			var i:int;
			
			super.read(data);
			
			// MATERIAL
			if (attrib & 256)
			{
				material = new Vector.<SEAObject>( data.readUnsignedByte() );	
				
				if (material.length == 1)
				{
					material[0] = sea.getSEAObject(data.readUnsignedInt());
				}
				else
				{
					i = 0;
					while ( i < material.length )	
					{
						var mat:uint = data.readUnsignedInt();
					
						if (mat > 0) material[i++] = sea.getSEAObject(mat-1);
						else material[i++] = undefined;
					}
				}
			}
			
			// MODIFIERS
			if (attrib & 512)
			{
				modifiers = new Vector.<SEAObject>( data.readUnsignedByte() );
				
				i = 0;
				while ( i < modifiers.length )				
					modifiers[i++] = sea.getSEAObject(data.readUnsignedInt());				
			}
			
			// REFERENCES
			if (attrib & 1024)
			{
				reference = {};
				reference.type = data.readUnsignedByte();
				reference.ref = sea.getSEAObject(data.readUnsignedInt());					
			}
			
			transform = ByteArrayUtils.readMatrix3D(data);
			
			geometry = sea.getSEAObject(data.readUnsignedInt());
		}
	}
}
