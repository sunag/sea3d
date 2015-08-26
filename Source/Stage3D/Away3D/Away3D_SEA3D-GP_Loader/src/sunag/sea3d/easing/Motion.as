package sunag.sea3d.easing
{
	import flash.utils.Dictionary;
	
	import sunag.sea3dgp;
	import sunag.sea3d.utils.TimeStep;
	
	use namespace sea3dgp;
	
	public class Motion
	{	
		private static var objectsDict:Dictionary = new Dictionary(true);
		private static var objectsList:Array = [];
		
		private static var mTime:Number = 0;
		
		private static var easingManager:Object = 
			{
				linear:Easing.linear,
				
				cubicIn:Easing.cubicIn,
				cubicOut:Easing.cubicOut,
				cubicInOut:Easing.cubicInOut,
				cubicOutIn:Easing.cubicOutIn,
					
				elasticIn:Easing.elasticIn,
				elasticOut:Easing.elasticOut,
				elasticInOut:Easing.elasticInOut,
				elasticOutIn:Easing.elasticOutIn				
			};
		
		public static function start(obj:Object, property:String, value:Number, duration:Number, easing:String, ...params):void
		{
			if (contains(obj, property)) 
				stop(obj, property);
			
			creatMotion(obj, property, value, duration, easing, params);
		}
		
		public static function stop(obj:Object, property:String):void
		{
			destroy(obj, property)
		}
		
		public static function contains(obj:Object, property:String):Boolean
		{
			return objectsDict[obj] && objectsDict[obj][property];
		}
		
		public static function destroy(obj:Object, property:String):void
		{
			var index:int = objectsList.indexOf(objectsDict[obj][property]);
			objectsList.splice(index, 1);
			
			for each(var onComplete:Function in objectsDict[obj].__complete)
			{
				onComplete();
			}
			
			delete objectsDict[obj][property];
			
			var c:Boolean = false;
			for each(var o:* in objectsDict[obj])
			{
				c = true;
				break;
			}
			
			if (!c) delete objectsDict[obj];
		}
		
		public static function addUpdate(obj:Object, callback:Function):void
		{
			objectsDict[obj].__update[callback] = callback;
		}
		
		public static function removeUpdate(obj:Object, callback:Function):void
		{
			delete objectsDict[obj].__update[callback];
		}
		
		public static function addComplete(obj:Object, callback:Function):void
		{
			objectsDict[obj].__complete[callback] = callback;
		}
		
		public static function removeComplete(obj:Object, callback:Function):void
		{
			delete objectsDict[obj].__complete[callback];
		}
		
		sea3dgp static function update():void
		{
			mTime = TimeStep.time;
			
			for each(var m:Object in objectsList)
			{
				var obj:Object = m.obj;						
				var duration:Number = m.duration;
				var method:Function = m.method;
				var property:String = m.property;
				
				var timer:Number = mTime - m.timer;
				var progress:Number = timer / duration;
				
				if (progress < 0) 
				{
					obj[property] = m.begin;
					destroy(obj, property);
				}
				else if (progress >= 1)
				{
					obj[property] = m.end;
					destroy(obj, property);
				}
				else 
				{	
					var factor:Number = 0;
					
					switch(method.length)
					{
						case 4:							
							factor = method(timer, 0, 1, duration);
							break;
						
						case 6:
							factor = method(timer, 0, 1, duration,  m.params[0],  m.params[1]);
							break;
					}
					
					obj[property] = m.begin + factor * (m.end - m.begin);
					
					for each(var onUpdate:Function in objectsDict[obj].__update)
					{
						onUpdate();
					}
				}							
			}				
		}
		
		sea3dgp static function creatMotion(obj:Object, property:String, value:Number, duration:Number, easing:String, params:Array=null):void
		{
			if (!objectsDict[obj]) 
			{
				objectsDict[obj] = {};
				objectsDict[obj].__update = new Dictionary(true);
				objectsDict[obj].__complete = new Dictionary(true);
			}
							
			var motion:Object = 
				{
					obj:obj,	
					duration:duration,
					timer:mTime,
					method:easingManager[easing] ? easingManager[easing] : easingManager["linear"],
					property:property,
					begin:Number(obj[property]),
					end:value,
					params:params
				};
						
			objectsDict[obj][property] = motion;
						
			objectsList.push(motion);
		}
	}
}