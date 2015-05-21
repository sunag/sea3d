package sunag.sea3d.framework
{
	import away3d.containers.ObjectContainer3D;
	
	import sunag.sea3dgp;
	
	use namespace sea3dgp;
	
	public class Particle extends Asset
	{
		sea3dgp static const TYPE:String = 'Particle/';
		
		sea3dgp var cloneContent:Boolean;
		sea3dgp var container:ObjectContainer3D;
		
		function Particle()
		{
			super(TYPE);
		}	
		
		sea3dgp function get content():ObjectContainer3D
		{
			if (container)
			{
				if (cloneContent)
					return container.clone() as ObjectContainer3D;
				
				cloneContent = true;
				
				return container;
			}
			
			return null;
		}
	}
}