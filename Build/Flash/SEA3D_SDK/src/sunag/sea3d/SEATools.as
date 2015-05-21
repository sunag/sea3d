package sunag.sea3d
{
	import flash.geom.Vector3D;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import sunag.sea3d.objects.SEAObject;

	public class SEATools
	{
		private static function isVector(obj:Object):Boolean 
		{
			return getQualifiedClassName(obj).indexOf('__AS3__.vec::Vector') == 0;
		}
		
		public static function clone(copy:SEAObject, hierarchy:Boolean=false):SEAObject
		{
			return SEATools.copy(copy, null, true, hierarchy);
		}
		
		public static function copy(copy:SEAObject, to:SEAObject=null, clone:Boolean=false, hierarchy:Boolean=false):SEAObject
		{
			var descriptor:XML = describeType(copy);
						
			if (!to)
			{				
				var SEAClass:Class = getDefinitionByName(descriptor.@name.toString()) as Class;
				
				if (SEAClass != SEAObject)
				{
					to = new SEAClass(copy.name, copy.sea);
				}				
				else 
				{
					to = new SEAObject(copy.name, copy.type, copy.sea);
				}
			}
			
			for each (var prop:XML in descriptor.variable)
			{
				var name:String = prop.@name.toString();
				var value:* = copy[name];
				
				if (clone)
				{
					if (value is Vector3D)
						value = value.clone();
					else if (isVector(value))
						value = value.concat()					
					else if (hierarchy && value is SEAObject)
						value = SEATools.copy(value, null, true, true);
							
					to[name] = value;					
				}
				else to[name] = value;
			}
			
			return to;
		}
	}
}