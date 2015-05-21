package sunag.animation
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import sunag.sunag;

	use namespace sunag;

	public class AnimationSet extends EventDispatcher
	{
		sunag var _anmList:Vector.<AnimationNode> = new Vector.<AnimationNode>();	
		sunag var _anm:Object = {};
		sunag var _dataCount:int = -1;
		
		public function removeAnimation(node:AnimationNode):void
		{
			delete _anm[node._name];
			
			_anmList.splice( _anmList.indexOf( node ), 1 );
			
			if (_anmList.length == 0)
				_dataCount = -1;
			
			notifyChange();
		}
		
		public function updateData():void
		{
			_dataCount = _anmList.length > 0 ? _anmList[0]._dataList.length : -1;
		}
		
		public function addAnimation(node:AnimationNode):void
		{			
			_anmList.push(_anm[node._name] = node);
			
			if (_dataCount == -1) 
				updateData();
			
			notifyChange();
		}
		
		public function getAnimationByName(name:String):AnimationNode
		{
			return _anm[name];
		}
		
		private function notifyChange():void
		{
			if (hasEventListener(Event.CHANGE))
				dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get animations():Vector.<AnimationNode>
		{
			return _anmList;
		}			
	}
}