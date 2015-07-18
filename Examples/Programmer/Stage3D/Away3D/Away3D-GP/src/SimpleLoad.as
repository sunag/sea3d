package 
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.events.Event;
	import sunag.sea3d.framework.Scene3D;

	[SWF(width="1024", height="632", backgroundColor="0x333333", frameRate="60")]
	public class SimpleLoad extends Sprite
	{
		public function SimpleLoad()
		{		
			SEA3DGP.init(this);
			
			var game:Scene3D = new Scene3D();
			game.name = "SEA3D - Car";
			game.load( "../assets/car.sea" );		
			
			game.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				var game2:Scene3D = game.clone() as Scene3D;
				game2.name = "game2";
				game2.position = new Vector3D(150, 0, 0);
				
				var game3:Scene3D = game.clone() as Scene3D;
				game3.name = "game2";
				game3.position = new Vector3D(-150, 0, 0);				
			});
		}
	}
}