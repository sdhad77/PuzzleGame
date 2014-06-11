package N2P2
{
    import starling.display.Sprite;
    import starling.utils.AssetManager;
    
    public class Game extends Sprite
    {
        private var _assetManager:AssetManager;
        
        private var _title:Title;
        private var _worldMap:WorldMap;
        private var _inGame:InGame;
        
        public function Game()
        {
            super();
        }
        
        public function start(assetManager:AssetManager):void
        {
            _assetManager = assetManager;
            
            startTitle();
        }
        
        public function startTitle():void
        {
            _title = new Title;
            _title.start(_assetManager);
            addChild(_title);
        }
        
        public function startWorldMap():void
        {
            _worldMap = new WorldMap;
            _worldMap.start(_assetManager);
            addChild(_worldMap);
        }
        
        public function startInGame(stageNum:Number):void
        {trace("stage" + stageNum);
            _inGame = new InGame;
            _inGame.start(_assetManager);
            addChild(_inGame);
        }
    }
}