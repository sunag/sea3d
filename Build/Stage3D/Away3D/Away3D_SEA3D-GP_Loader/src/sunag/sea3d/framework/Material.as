package sunag.sea3d.framework
{
	import away3d.materials.MaterialBase;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class Material extends Asset
	{
		sea3dgp static const TYPE:String = 'Material/';
						
		sea3dgp var scope:MaterialBase;		
		
		public function Material(scope:MaterialBase)
		{
			super(TYPE);
			
			this.scope = scope;
		}
	}
}