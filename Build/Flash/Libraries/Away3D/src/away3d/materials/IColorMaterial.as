package away3d.materials
{
	

	public interface IColorMaterial extends IPassMaterial
	{		
		function get color() : uint
		
		function set color(value : uint) : void
	}
}