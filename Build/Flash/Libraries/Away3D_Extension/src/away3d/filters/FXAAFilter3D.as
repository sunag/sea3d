/**
 * @about: https://gist.github.com/iY0Yi/9214656
 * */
package away3d.filters
{
	import away3d.filters.Filter3DBase;
	import away3d.filters.tasks.Filter3DFXAATask;
	
	public class FXAAFilter3D extends Filter3DBase
	{
		private var _fxaaTask:Filter3DFXAATask;
		
		public function FXAAFilter3D(span:Number = 8, reduce:Number = 128, w:Number = 1024, h:Number = 1024)
		{
			super();
			_fxaaTask = new Filter3DFXAATask(span, reduce, w, h);
			addTask(_fxaaTask);
		}
		
		public function get span():Number
		{
			return _fxaaTask.span;
		}
		
		
		public function set span(value:Number):void
		{
			_fxaaTask.span = value;
		}
		
		
		public function get reduce():Number
		{
			return _fxaaTask.reduce;
		}
		
		
		public function set reduce(value:Number):void
		{
			_fxaaTask.reduce = value;
		}
	}
}