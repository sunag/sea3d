package sunag.sea3d.framework
{
	import away3d.entities.JointObject;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAJointObject;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class JointObject extends Object3D
	{
		sea3dgp var jointObj:away3d.entities.JointObject;
		
		sea3dgp var mesh:Mesh;
		
		public function JointObject()
		{
			super(jointObj = new away3d.entities.JointObject(null, 0, false));
		}
		
		public function set target(val:Mesh):void
		{
			if ((mesh = val)) 
			{
				jointObj.target = target.mesh;
			}
			
			jointObj.autoUpdate = mesh != null;
		}
		
		public function get target():Mesh
		{
			return mesh;
		}
		
		public function set jointIndex(index:Number):void
		{
			jointObj.jointIndex = index;
			jointObj.update();
		}
		
		public function get jointIndex():Number
		{
			return jointObj.jointIndex;
		}
		
		public function set jointName(name:String):void
		{
			jointObj.jointName = name;
			jointObj.update();
		}
		
		public function get jointName():String
		{
			return jointObj.jointName;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	JOINT OBJECT
			//
			
			var jnt:SEAJointObject = sea as SEAJointObject;
			
			target = jnt.target.tag;			
			jointIndex = jnt.joint;
		}
	}
}