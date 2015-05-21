package sunag.sea3d.modules
{
	import sunag.sunag;
	import sunag.sea3d.objects.SEAParticleContainer;
	import sunag.sea3d.objects.SEASparticle;

	use namespace sunag;
	
	public class ParticleModuleBase extends ModuleBase
	{
		public function ParticleModuleBase()
		{
			regClass(SEASparticle);		
			regClass(SEAParticleContainer);
		}		
	}
}