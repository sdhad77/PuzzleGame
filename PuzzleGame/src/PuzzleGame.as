package
{
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    
    import N2P2.root.Game;
    import N2P2.utils.EmbeddedAssets;
    
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
            myStarling = new Starling(Game, stage, new Rectangle(0,0,768,1024));
            myStarling.addEventListener(Event.ROOT_CREATED, onRootCreated);
            myStarling.showStats = true;myStarling.showStatsAt("left","top",3);
            myStarling.viewPort = new Rectangle(0,40,480,640);
            myStarling.start();
        }
        
        private function onRootCreated(event:Event, game:Game):void
        {
            assetManager = new AssetManager();
            
            assetManager.addTextureAtlas("titleUI", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.titleUISheet()), XML(new EmbeddedAssets.titleUIXml())));
            assetManager.addTextureAtlas("worldMap", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.worldMapSheet()), XML(new EmbeddedAssets.worldMapXml())));
            assetManager.addTextureAtlas("worldMapUI", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.worldMapUISheet()), XML(new EmbeddedAssets.worldMapUIXml())));
            assetManager.addTextureAtlas("inGameUI", new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.inGameUISheet()), XML(new EmbeddedAssets.inGameUIXml())));
            assetManager.addXml("stageInfo", XML(new EmbeddedAssets.stageInfoXml()));
            
            game.start(assetManager);
        }
    }
}