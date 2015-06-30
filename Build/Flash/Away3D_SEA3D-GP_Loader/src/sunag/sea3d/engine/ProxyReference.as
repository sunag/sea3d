package sunag.sea3d.engine
{
	import flash.utils.Proxy;
	import flash.system.ApplicationDomain;
	import flash.utils.flash_proxy;
	
	public dynamic class ProxyReference extends Proxy
	{
		private var ref:Array = [];
		
		override flash_proxy function callProperty(methodName:*, ... args):* 
		{
			return ref[methodName] ? ref[methodName].apply(ref, args) : ApplicationDomain.currentDomain.getDefinition(methodName);		 
		}
		
		override flash_proxy function getProperty(name:*):* 
		{
			return ref[name] || ApplicationDomain.currentDomain.getDefinition(name);
		}
		
		override flash_proxy function setProperty(name:*, val:*):void 
		{
			ref[name] = val;
		}
	}
}