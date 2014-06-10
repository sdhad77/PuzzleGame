package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    import N2P2.EmbeddedAssets;
    import N2P2.Game;
    
    import starling.core.Starling;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.AssetManager;
    
    [SWF(frameRate="60", width="768", height="1024", backgroundColor="0xffffff")]
    public class PuzzleGame extends Sprite
    {
        private var myStarling:Starling;
        private var assetManager:AssetManager;
        
        public function PuzzleGame()
        {
            // support autoOrients
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            myStarling = new Starling(Game, stage);
            myStarling.addEventListener(Event.ROOT_CREATED, onRootCreated);
            myStarling.showStats = true;
            myStarling.start();
        }
        
        private function onRootCreated(event:Event, game:Game):void
        {
            assetManager = new AssetManager();
            
            assetManager.addTextureAtlas("ui", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.UISheet()), XML(new EmbeddedAssets.UIXml())));
            assetManager.addTextureAtlas("char", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.CharSheet()), XML(new EmbeddedAssets.CharXml())));
            assetManager.addTextureAtlas("char2", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.Char2Sheet()), XML(new EmbeddedAssets.Char2Xml())));
            
            game.start(assetManager);
        }
    }
}