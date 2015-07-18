package awayphysics.collision.shapes {
	import AWPC_Run.CModule;
	import AWPC_Run.createHeightmapDataBufferInC;
	import AWPC_Run.removeHeightmapDataBufferInC;
	import AWPC_Run.createTerrainShapeInC;
	import AWPC_Run.disposeCollisionShapeInC;
	
	import away3d.core.base.Geometry;
	import awayphysics.extend.AWPTerrain;

	public class AWPHeightfieldTerrainShape extends AWPCollisionShape {
		private var dataPtr : uint;

		private var _geometry:Geometry;
		
		 /**
		  * create terrain with the heightmap data
		  */
		public function AWPHeightfieldTerrainShape(terrain : AWPTerrain) {
			_geometry = terrain.geometry;
			var dataLen : int = terrain.sw * terrain.sh;
			dataPtr = createHeightmapDataBufferInC(dataLen);

			var data : Vector.<Number> = terrain.heights;
			for (var i : int = 0; i < dataLen; i++ ) {
				CModule.writeFloat(dataPtr+i*4,data[i] / _scaling);
			}

			pointer = createTerrainShapeInC(dataPtr, terrain.sw, terrain.sh, terrain.lw / _scaling, terrain.lh / _scaling, 1, -terrain.maxHeight / _scaling, terrain.maxHeight / _scaling, 1);
			super(pointer, 10);
		}

		override public function dispose() : void {
			m_counter--;
			if (m_counter > 0) {
				return;
			}else {
				m_counter = 0;
			}
			if (!_cleanup) {
				_cleanup = true;
				removeHeightmapDataBufferInC(dataPtr);
				disposeCollisionShapeInC(pointer);
			}
		}
		
		public function get geometry():Geometry {
			return _geometry;
		}
	}
}