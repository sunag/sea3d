package away3d.loaders.parsers
{
	import away3d.arcane;
	import away3d.library.assets.IAsset;
	import away3d.loaders.parsers.particleSubParsers.utils.SingleResourceDependency;
	
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class CompositeParserBase extends ParserBase
	{
		private var _loadedAssetCache:Object = {};
		
		protected var _root:CompositeParserBase;
		
		protected var _children:Vector.<CompositeParserBase>;
		
		private var _childParsingComplete:Boolean;
		
		protected var _isFirstParsing:Boolean;
		
		private var _numProcessed:int;
		
		public function CompositeParserBase()
		{
			super(ParserDataFormat.PLAIN_TEXT);
			_root = this;
		}
		
		public function get childParsingComplete():Boolean
		{
			return _childParsingComplete;
		}
		
		public function set childParsingComplete(value:Boolean):void
		{
			_childParsingComplete = value;
		}
		
		public function addSubParser(subParser:CompositeParserBase):void
		{
			_children ||= new Vector.<CompositeParserBase>;
			if (_children.indexOf(subParser) != -1)
				throw(new Error("Duplicated add"));
			_children.push(subParser);
			subParser.root = _root;
		}
		
		override public function parseAsync(data:*, frameLimit:Number = 15):void
		{
			if (data is String || data is ByteArray)
			{
				data = JSON.parse(data);
			}
			_numProcessed = 0;
			_isFirstParsing = true;
			if (_root == this)
			{
				super.parseAsync(data, frameLimit);
				//speed up
				onInterval();
			}
			else
			{
				_data = data;
			}
		}
		
		override protected function onInterval(event:TimerEvent = null):void
		{
			trace("important for debug ", this);
			super.onInterval(event);
		}
		
		override protected function proceedParsing():Boolean
		{
			_isFirstParsing = false;
			if (_root.dependencies.length)
			{
				pauseAndRetrieveDependencies();
				return MORE_TO_PARSE;
			}
			if (!_children)
				return PARSING_DONE;
			
			while (_numProcessed < _children.length)
			{
				if (_children[_numProcessed].proceedParsing() == PARSING_DONE)
				{
					_numProcessed++;
				}
				else
				{
					return MORE_TO_PARSE;
				}
			}
			return PARSING_DONE;
		}
		
		
		override protected function addDependency(id:String, req:URLRequest, retrieveAsRawData:Boolean = false, data:* = null, suppressErrorEvents:Boolean = false):void
		{
			_root.dependencies.push(new SingleResourceDependency(id, req, data, this, retrieveAsRawData, suppressErrorEvents));
		}
		
		override protected function finalizeAsset(asset:IAsset, name:String = null):void
		{
			_root == this ? super.finalizeAsset(asset, name) : _root.finalizeAsset(asset, name);
		}
		
		override protected function hasTime():Boolean
		{
			return _root == this ? super.hasTime() : _root.hasTime();
		}
		
		override public function set parsingFailure(b:Boolean):void
		{
			_root.parsingFailure = b;
			_root == this ? super.parsingFailure = b : _root.parsingFailure = b;
		}
		
		override public function get parsingFailure():Boolean
		{
			return _root == this ? super.parsingFailure : _root.parsingFailure;
		}
		
		override protected function finishParsing():void
		{
			_root == this ? super.finishParsing() : null;
		}
		
		override protected function dieWithError(message:String = 'Unknown parsing error'):void
		{
			//throw(new Error(message));
			_root == this ? super.dieWithError(message) : _root.dieWithError(message);
		}
		
		override protected function pauseAndRetrieveDependencies():void
		{
			_root == this ? super.pauseAndRetrieveDependencies() : null;
		}
		
		override public function get parsingPaused():Boolean
		{
			return _root == this ? super.parsingPaused : _root.parsingPaused;
		}
		
		public function get root():CompositeParserBase
		{
			return _root;
		}
		
		public function set root(value:CompositeParserBase):void
		{
			_root = value;
			if (_children)
				for each (var child:CompositeParserBase in _children)
					child.root = value;
		}
		
		arcane function addAssets(url:String, assets:Vector.<IAsset>):void
		{
			_loadedAssetCache[url] = assets;
		}
		
		arcane function getAssets(url:String):Vector.<IAsset>
		{
			return _loadedAssetCache[url] as Vector.<IAsset>;
		}
	
	}

}
