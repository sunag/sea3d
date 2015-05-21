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

package sunag.manager
{
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	import sunag.events.SEA3DManagerEvent;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.sea3d.config.IConfig;
	
	public class SEA3DManager extends EventDispatcher
	{
		private static var _instance:SEA3DManager;
		
		public static function set instance(value:SEA3DManager):void
		{
			_instance = value;
		}
		
		public static function get instance():SEA3DManager
		{
			return _instance || (_instance = new SEA3DManager(new DefaultConfig()));
		}
						
		/**
		 * Dispatched if all SEA3D files is loaded.
		 * 
		 * @eventType sunag.events.SEA3DManagerEvent
		 * @see sunag.sea3d.SEA3D
		 */
		[Event(name="complete",type="sunag.events.SEA3DManagerEvent")]
		
		private var _config:IConfig;
		
		public function SEA3DManager(config:IConfig) 
		{
			_config = config;
		}
		
		private var _assets:Object = {};			
		private var _list:Vector.<SEAObject> = new Vector.<SEAObject>();
		private var _sea3d:SEA3D;
		
		public function load(urlRequest:URLRequest, ns:String, onComplete:Function=null, onProgress:Function=null, tag:Object=null):void
		{
			var sea3d:SEA3D = new SEA3D(_config);
			sea3d.tag = tag;			
			_list.push( new SEAObject(sea3d,urlRequest,ns,onComplete,onProgress,tag) );
			next();
		}
		
		public function get config():IConfig
		{
			return _config;
		}
		
		private function next():void
		{
			if (_sea3d) return;
			
			_sea3d = seaobj.sea3d;	
			_sea3d.addEventListener(SEAEvent.COMPLETE, onComplete, false, 0, true);
			_sea3d.addEventListener(SEAEvent.PROGRESS, onProgress, false, 0, true);
			_sea3d.load(seaobj.urlRequest);
		}
		
		public function numWaiting():int
		{
			return _list.length;
		}
		
		private function get seaobj():SEAObject
		{
			return _list[0];
		}
		
		public function getSEA3D(ns:String):SEA3D
		{
			return _assets[ns];
		}
		
		public function dispose():void
		{
			_assets = {};			
		}
		
		private function onProgress(e:SEAEvent):void
		{
			if (seaobj.onProgress)
				seaobj.onProgress(e);	
		}
		
		private function onComplete(e:SEAEvent):void
		{
			var obj:SEAObject = seaobj;
			
			_sea3d.removeEventListener(SEAEvent.COMPLETE, onComplete);
			_sea3d.removeEventListener(SEAEvent.PROGRESS, onProgress);
			
			if (obj.onComplete)
				obj.onComplete(e);	
			
			_list.shift();
			
			_assets[obj.ns] = _sea3d;
			
			_sea3d = null;
			
			if (_list.length == 0)
				dispatchEvent(new SEA3DManagerEvent(SEA3DManagerEvent.COMPLETE));			
			else next();
		}
	}
}
import flash.net.URLRequest;

import sunag.sea3d.SEA3D;

class SEAObject 
{
	public var sea3d:SEA3D;
	public var urlRequest:URLRequest;
	public var ns:String;
	public var onComplete:Function;
	public var onProgress:Function;
	public var tag:Object;
	
	public function SEAObject(sea3d:SEA3D, urlRequest:URLRequest, ns:String, onComplete:Function, onProgress:Function, tag:Object=null)
	{
		this.sea3d = sea3d;
		this.urlRequest = urlRequest;
		this.ns = ns;
		this.onComplete = onComplete;
		this.onProgress = onProgress;
		this.tag = tag;
	}
}