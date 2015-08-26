package away3d.filters
{
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.Filter3DBase;
	import away3d.filters.tasks.Filter3DDoubleBufferCopyTask;
	
	public class MotionBlurRGBFilter3D extends Filter3DBase
	{
		private var _compositeTask:Filter3DXFadeCompositeTask;
		private var _copyTask:Filter3DDoubleBufferCopyTask;
		
		public function MotionBlurRGBFilter3D(r:Number = .65, g:Number = .65, b:Number = .65)
		{
			super();
			_compositeTask = new Filter3DXFadeCompositeTask(r, g, b);
			_copyTask = new Filter3DDoubleBufferCopyTask();
			
			addTask(_compositeTask);
			addTask(_copyTask);
		}
		
		public function get r():Number
		{
			return _compositeTask.r;
		}
		
		public function set r(value:Number):void
		{
			_compositeTask.r = value;
		}
		
		public function get g():Number
		{
			return _compositeTask.g;
		}
		
		public function set g(value:Number):void
		{
			_compositeTask.g = value;
		}
		
		public function get b():Number
		{
			return _compositeTask.b;
		}
		
		public function set b(value:Number):void
		{
			_compositeTask.b = value;
		}
		
		override public function update(stage:Stage3DProxy, camera:Camera3D):void
		{
			// TODO: not used
			camera = camera;
			
			_compositeTask.overlayTexture = _copyTask.getMainInputTexture(stage);
			_compositeTask.target = _copyTask.secondaryInputTexture;
		}
	}
}

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;

import away3d.arcane;
import away3d.cameras.Camera3D;
import away3d.core.managers.Stage3DProxy;
import away3d.filters.tasks.Filter3DTaskBase;

use namespace arcane;

class Filter3DXFadeCompositeTask extends Filter3DTaskBase
{
	private var _data:Vector.<Number>;
	private var _overlayTexture:TextureBase;
	
	public function Filter3DXFadeCompositeTask(r:Number, g:Number, b:Number)
	{
		super();
		_data = Vector.<Number>([ r, g, b, 0 ]);
	}
	
	public function get overlayTexture():TextureBase
	{
		return _overlayTexture;
	}
	
	public function set overlayTexture(value:TextureBase):void
	{
		_overlayTexture = value;
	}
	
	public function get r():Number
	{
		return _data[0];
	}
	
	public function set g(value:Number):void
	{
		_data[1] = value;
	}
	
	public function get g():Number
	{
		return _data[1];
	}
	
	public function set b(value:Number):void
	{
		_data[2] = value;
	}
	
	public function get b():Number
	{
		return _data[2];
	}
	
	public function set r(value:Number):void
	{
		_data[0] = value;
	}
	
	override protected function getFragmentCode():String
	{
		return "tex ft0, v0, fs0 <2d,nearest>	\n" +
			"tex ft1, v0, fs1 <2d,nearest>	\n" +
			"sub ft1, ft1, ft0				\n" +
			"mul ft1, ft1, fc0			     \n" +
			"add oc, ft1, ft0				\n";
	}
	
	override public function activate(stage3DProxy:Stage3DProxy, camera3D:Camera3D, depthTexture:Texture):void
	{
		var context:Context3D = stage3DProxy._context3D;
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 1);
		context.setTextureAt(1, _overlayTexture);
	}
	
	override public function deactivate(stage3DProxy:Stage3DProxy):void
	{
		stage3DProxy._context3D.setTextureAt(1, null);
	}
}
