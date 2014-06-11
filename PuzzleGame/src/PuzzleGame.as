package
{
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    
    import N2P2.EmbeddedAssets;
    import N2P2.Game;
    
    import starling.core.Starling;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.AssetManager;
    
    [SWF(frameRate="60")]
    public class PuzzleGame extends Sprite
    {
        private var myStarling:Starling;
        private var assetManager:AssetManager;
        
        public function PuzzleGame()
        {
            myStarling = new Starling(Game, stage, new Rectangle(0,0,stage.fullScreenWidth,stage.fullScreenHeight));
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