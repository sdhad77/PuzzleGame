package
{
    import com.sdh.AneFunctionExtension;
    
    import flash.desktop.NativeApplication;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    
    import N2P2.root.Game;
    import N2P2.utils.EmbeddedAssets;
    
    import starling.core.Starling;
    import starling.events.Event;
    import starling.events.KeyboardEvent;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.AssetManager;
    
    [SWF(frameRate="60", backgroundColor="0x0")]
    public class PuzzleGame extends Sprite
    {
        private var myStarling:Starling;
        private var assetManager:AssetManager;
        private var _aneFunction:AneFunctionExtension;
        
        public function PuzzleGame()
        {
            _aneFunction = new AneFunctionExtension;
            
            myStarling = new Starling(Game, stage, new Rectangle(0,0,768,1024));
            myStarling.addEventListener(Event.ROOT_CREATED, onRootCreated);
            myStarling.showStats = true;myStarling.showStatsAt("left","top",2);
            myStarling.viewPort = calculateViewPortRectangle();
            myStarling.start();
        }
        
        private function onRootCreated(event:Event, game:Game):void
        {
            game.addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
            
            assetManager = new AssetManager();
            
            assetManager.addTextureAtlas("titleUI", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.titleUISheet()), XML(new EmbeddedAssets.titleUIXml())));
            assetManager.addTextureAtlas("worldMap", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.worldMapSheet()), XML(new EmbeddedAssets.worldMapXml())));
            assetManager.addTextureAtlas("worldMapUI", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.worldMapUISheet()), XML(new EmbeddedAssets.worldMapUIXml())));
            assetManager.addTextureAtlas("inGameUI", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.inGameUISheet()), XML(new EmbeddedAssets.inGameUIXml())));
            assetManager.addXml("stageInfo", XML(new EmbeddedAssets.stageInfoXml()));
            
            game.start(assetManager);
        }
        
        /**
         * 눌린 키가 무엇인지 확인하고 해당하는 함수 작동시킴
         * @param event 키보드 이벤트
         */
        private function keyPress(event:KeyboardEvent):void
        {
            if(event.keyCode == Keyboard.BACK)
            {
                event.preventDefault();
                if(_aneFunction.backPress("Null") == true) NativeApplication.nativeApplication.exit();
            }
        }
        
        /**
         * viewPort를 디바이스 화면크기에 맞게끔 계산해 주는 함수
         * @return 변경할 viewPort
         */
        private function calculateViewPortRectangle():Rectangle
        {
            var rect:Rectangle = new Rectangle(0,0,stage.fullScreenWidth,stage.fullScreenHeight);
            
            if(stage.fullScreenWidth/stage.fullScreenHeight >= 0.75)
            {
                rect.width = 0.75*stage.fullScreenHeight;
                rect.x = (stage.fullScreenWidth - rect.width)/4;
            }
            else
            {
                rect.height = stage.fullScreenWidth/0.75;
                rect.y = (stage.fullScreenHeight - rect.height)/4;
            }
            
            return rect;
        }
    }
}