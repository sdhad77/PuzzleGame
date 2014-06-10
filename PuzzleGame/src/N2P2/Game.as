package N2P2
{
    import starling.display.Sprite;
    import starling.events.Event;
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
        
        private function startTitle():void
        {
            _title = new Title;
            _title.start(_assetManager);
            _title.addEventListener(Event.REMOVED_FROM_STAGE, startWorldMap);
            addChild(_title);
        }
        
        private function startWorldMap():void
        {
            _title.removeEventListener(Event.REMOVED_FROM_STAGE, startWorldMap);
            _title = null;
            
            _worldMap = new WorldMap;
            _worldMap.start(_assetManager);
            addChild(_worldMap);
        }
        
        public function startInGame():void
        {
            _inGame = new InGame;
            _inGame.start(_assetManager);
            addChild(_inGame);
        }
    }
}