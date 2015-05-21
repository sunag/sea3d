package away3d.loaders.parsers.particleSubParsers
{
	import away3d.loaders.parsers.particleSubParsers.geometries.*;
	import away3d.loaders.parsers.particleSubParsers.geometries.shapes.*;
	import away3d.loaders.parsers.particleSubParsers.materials.*;
	import away3d.loaders.parsers.particleSubParsers.nodes.*;
	import away3d.loaders.parsers.particleSubParsers.values.color.*;
	import away3d.loaders.parsers.particleSubParsers.values.fourD.*;
	import away3d.loaders.parsers.particleSubParsers.values.matrix.*;
	import away3d.loaders.parsers.particleSubParsers.values.oneD.*;
	import away3d.loaders.parsers.particleSubParsers.values.property.InstancePropertySubParser;
	import away3d.loaders.parsers.particleSubParsers.values.threeD.*;
	
	public class AllSubParsers
	{
		public static const ALL_PARTICLE_NODES:Array = [ParticleTimeNodeSubParser, ParticleVelocityNodeSubParser, ParticleAccelerationNodeSubParser, ParticlePositionNodeSubParser, ParticleBillboardNodeSubParser, ParticleFollowNodeSubParser, ParticleScaleNodeSubParser, ParticleColorNodeSubParser, ParticleOscillatorNodeSubParser, ParticleRotationalVelocityNodeSubParser, ParticleOrbitNodeSubParser, ParticleBezierCurveNodeSubParser, ParticleSpriteSheetNodeSubParser, ParticleRotateToHeadingNodeSubParser, ParticleSegmentedColorNodeSubParser, ParticleInitialColorNodeSubParser, ParticleSegmentedScaleNodeSubParser, ParticleUVNodeSubParser];
		
		public static const ALL_GEOMETRIES:Array = [SingleGeometrySubParser];
		
		public static const ALL_MATERIALS:Array = [TextureMaterialSubParser, ColorMaterialSubParser];
		
		public static const ALL_SHAPES:Array = [PlaneShapeSubParser, ExternalShapeSubParser, CubeShapeSubParser, SphereShapeSubParser, CylinderShapeSubParser];
		
		public static const ALL_ONED_VALUES:Array = [OneDConstValueSubParser, OneDRandomVauleSubParser, OneDCurveValueSubParser];
		public static const ALL_THREED_VALUES:Array = [ThreeDConstValueSubParser, ThreeDCompositeValueSubParser, ThreeDSphereValueSubParser, ThreeDCylinderValueSubParser];
		public static const ALL_FOURD_VALUES:Array = [FourDCompositeWithOneDValueSubParser, FourDCompositeWithThreeDValueSubParser];
		public static const ALL_COLOR_VALUES:Array = [CompositeColorValueSubParser, ParticleSegmentedColorNodeSubParser];
		public static const ALL_MATRIX3DS:Array = [Matrix3DCompositeValueSubParser];
		public static const ALL_GLOBAL_VALUES:Array = [];
		public static const ALL_PROPERTIES:Array = [InstancePropertySubParser];
	}

}
