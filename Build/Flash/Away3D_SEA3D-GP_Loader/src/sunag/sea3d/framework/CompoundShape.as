package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import awayphysics.collision.shapes.AWPCompoundShape;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class CompoundShape extends Shape
	{
		sea3dgp var shp:AWPCompoundShape;
		sea3dgp var shapes:Array = [];
		
		public function CompoundShape()
		{
			scope = shp = new AWPCompoundShape();
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	COMPOUND SHAPE
			//
			
			
		}
		
		public function get shape():Array
		{
			return shapes;
		}
		
		public function contains(shape:Shape):Boolean
		{
			return shapes.indexOf(shape) != -1;
		}
		
		public function addShape(shape:Shape, localPos:Vector3D=null, localRot:Vector3D=null):void
		{
			shp.addChildShape(shape.scope, localPos, localRot);
			
			shapes.push(shape);
		}
		
		public function removeShape(shape:Shape):void
		{
			shp.removeChildShapeByIndex(shapes.indexOf(shape));
			
			shapes.splice(shapes.indexOf(shape), 1);
		}
	}
}