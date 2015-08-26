package awayphysics {
	public class AWPBase {
		/**
		 * 1 visual units equal to 0.01 bullet meters by default, this value is inversely with physics world scaling
		 * refer to http://www.bulletphysics.org/mediawiki-1.5.8/index.php?title=Scaling_The_World
		 */
		protected static var _scaling : Number = 100;
		protected var _cleanup:Boolean = false;
		public var pointer : uint;
	}
}