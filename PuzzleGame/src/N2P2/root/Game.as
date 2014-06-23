package N2P2.root
{
    import N2P2.root.child.InGame;
    import N2P2.root.child.Title;
    import N2P2.root.child.WorldMap;
    import N2P2.utils.GlobalData;
    
    import starling.display.Sprite;
    import starling.utils.AssetManager;
    
    /**
     * root 클래스입니다.</br>
     * 이 클래스에서 다른 클래스들을 addChild하는 구조입니다.
     * @author 신동환
     */
    public class Game extends Sprite
    {
        private var _assetManager:AssetManager;
        
        private var _title:Title;
        private var _worldMap:WorldMap;
        private var _inGame:InGame;
        private var _globalData:GlobalData;
        
        public function Game()
        {
            super();
        }
        
        public function start(assetManager:AssetManager):void
        {
            _assetManager = assetManager;
            
            startTitle();
        }
        
        /**
         * 타이틀을 생성하고 보여주는 함수
         */
        public function startTitle():void
        {
            _title = new Title;
            _title.start(_assetManager);
            addChild(_title);
        }
        
        /**
         * 월드맵을 생성하고 보여주는 함수
         */
        public function startWorldMap():void
        {
            _worldMap = new WorldMap;
            _worldMap.start(_assetManager);
            addChild(_worldMap);
        }
        
        /**
         * InGame화면을 생성하고 보여주는 함수
         * @param stageNum InGame에서 실행할 스테이지 번호
         */
        public function startInGame(stageNum:Number):void
        {
            initGlobalData();
            
            _inGame = new InGame;
            _inGame.start(_assetManager, stageNum);
            addChild(_inGame);
        }
        
        /**
         * 전역데이터들을 사용하기 위해 클래스 초기화하는 함수입니다.
         */
        public function initGlobalData():void
        {
            _globalData = new GlobalData(_assetManager);
        }
    }
}