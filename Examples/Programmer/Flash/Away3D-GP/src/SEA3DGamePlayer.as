package 
{
	import flash.display.Sprite;
	import flash.net.FileFilter;
	
	import sunag.sea3dgp;
	import sunag.player.PlayerEvent;
	import sunag.player.SEA3DLogo;
	import sunag.player.UploadButton;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.framework.Scene3D;
	
	[SWF(width="1024", height="632", backgroundColor="0x333333", frameRate="60")]
	public class SEA3DGamePlayer extends Sprite
	{
		private var uploadButton:UploadButton;
		private var sea3dLogo:SEA3DLogo;
		private var game:Scene3D;
		
		public function SEA3DGamePlayer()
		{							
			SEA3DGP.init(this);
			
			addChild( uploadButton = new UploadButton() );
			uploadButton.x = uploadButton.y = 20;
			uploadButton.buttonMode = true;
			uploadButton.fileFilter = [new FileFilter("Sunag Entertainment Assets (*.sea)","*.sea")];
			uploadButton.addEventListener(PlayerEvent.UPLOAD, onUpload);
			
			addChild( sea3dLogo = new SEA3DLogo() );
		}
		
		private function onUpload(e:PlayerEvent):void
		{
			if (sea3dLogo)
			{
				removeChild( sea3dLogo );
				sea3dLogo = null;
			}
			
			if (game)
			{
				game.dispose();
			}
			
			game = new Scene3D();
			game.sea3dgp::loadScene( uploadButton.data );
		}
	}
}