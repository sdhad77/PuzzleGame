package N2P2.root.child.ingame.utils
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Linear;
    
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import N2P2.root.child.ingame.InGame;
    import N2P2.utils.GlobalData;
    
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    
    /**
     * 게임 보드 클래스입니다.</br>
     * 게임과 관련된 처리들은 이곳에서 진행되며, 미션 종류에 따라 상속하여 개발할수 있도록 하였습니다.
     * @author 신동환
     */
    public class Board extends Sprite
    {
        private var _tiles:Vector.<Vector.<Tile>>; //보드에 존재하는 타일
        private var _inGameStageInfo:StageInfo;    //게임 스테이지 정보
        private var _stageNum:int;                 //현재 스테이지
        private var _isUpdating:Boolean;           //현재 업데이트 중인지
        
        private var _hintTiles:Sprite; //힌트가 저장되는 스프라이트
        private var _hintTimer:Timer   //힌트를 보여주는데 사용할 타이머
        
        private var _mouseButtonDown:Boolean; //마우스 버튼이 눌린 상태인지 확인하는 변수
        
        private var _currentTileX:int; //터치한 타일의 인덱스
        private var _currentTileY:int; //터치한 타일의 인덱스
        private var _newTileX:int;     //터치후 move하다가 선택된 타일의 인덱스
        private var _newTileY:int;     //터치후 move하다가 선택된 타일의 인덱스
        
        private var _horizontalResult:Array = new Array; //보드에서 가로로 검사한 결과가 저장되는 배열.
        private var _verticalResult:Array = new Array;   //보드에서 세로로 검사한 결과가 저장되는 배열.
        private var _crossResult:Array = new Array;      //보드에서  가로세로를 검사한 결과가 저장되는 배열.
        
        public function Board(stageNum:Number)
        {
            super();
            
            _stageNum = stageNum;
            
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }
        
        private function addedToStage():void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            
            init(_stageNum);
        }
        
        public function init(stageNum:Number):void
        {
            _isUpdating = false;
            TweenLite.defaultEase = Linear.easeNone;
            
            loadGameStage(stageNum);
            initTiles();
            initHint();
            resultClear();
            
            (this.parent as InGame).updatePoint(_inGameStageInfo.point);
            (this.parent as InGame).updateMoveNum(_inGameStageInfo.moveNum);
        }
        
        /**
         * xml파일에서 게임 스테이지 정보를 읽어오는 함수
         * @param stageNum 읽어올 스테이지
         * @param assetManager xml이 저장되어있는 매니져
         */
        private function loadGameStage(stageNum:Number):void
        {
            _inGameStageInfo = new StageInfo;
            _inGameStageInfo.parseStageInfoXml(GlobalData.ASSET_MANAGER.getXml("stageInfo"), stageNum);
        }
        
        /**
         * 보드에 타일들을 위치시키는 함수입니다.
         */
        private function initTiles():void
        {
            var upTileNum:int;
            var leftTileNum:int;
            var tileNum:int;
            
            _tiles = new Vector.<Vector.<Tile>>;
            
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++)
            {
                _tiles.push(new Vector.<Tile>);
                
                for(var j:int=0; j < GlobalData.FIELD_WIDTH; j++)
                {
                    //자신의 왼쪽, 위쪽에 있는 타일들의 num을 저장합니다.
                    if(i == 0 || j == 0)
                    {
                        if(i == 0) upTileNum   = -1;
                        else       upTileNum   = _tiles[i-1][j].num;
                        if(j == 0) leftTileNum = -1;
                        else       leftTileNum = _tiles[i][j-1].num;
                    }
                    else
                    {
                        upTileNum = _tiles[i-1][j].num;
                        leftTileNum = _tiles[i][j-1].num;
                    }
                    
                    //연속되는 타일이 생기지 않도록 랜덤을 반복합니다.
                    tileNum = Math.floor((Math.random())*GlobalData.TILE_CHAR);
                    while(tileNum == upTileNum || tileNum == leftTileNum) tileNum = Math.floor((Math.random())*GlobalData.TILE_CHAR);
                    
                    //타일 생성, 배치
                    _tiles[i].push(new Tile(tileNum));
                    _tiles[i][j].x = j * GlobalData.TILE_LENGTH;
                    _tiles[i][j].y = i * GlobalData.TILE_LENGTH;
                    _tiles[i][j].addEventListener(starling.events.TouchEvent.TOUCH, touchTile);
                    addChild(_tiles[i][j]);
                    
                    //안보이는 타일이면 visible false로.
                    if(_inGameStageInfo.board[i][j] == 1) _tiles[i][j].visibleOff();
                }
            }
        }
        
        /**
         * 힌트 타일을 초기화 하는 함수입니다.
         */
        private function initHint():void
        {
            _hintTiles = new Sprite;
            _hintTiles.touchable = false;
            _hintTiles.visible = false;
            addChild(_hintTiles);
            
            _hintTimer = new Timer(3000, 1);
            _hintTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hintOn);
            
            hintCheckAndMark();
            _hintTimer.start();
        }
        
        /**
         * 타일의 터치이벤트 입니다.
         */
        private function touchTile(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if(touch != null)
            {
                if(touch.phase == TouchPhase.BEGAN)
                {
                    _mouseButtonDown = true;
                    hintOff();
                    _hintTimer.stop();
                    
                    //현재 터치한 타일의 좌표로 인덱스를 구하여 저장합니다.
                    _currentTileX = (touch.globalX - this.x) / GlobalData.TILE_LENGTH_SCALED;
                    _currentTileY = (touch.globalY - this.y) / GlobalData.TILE_LENGTH_SCALED;
                }
                else if(touch.phase == TouchPhase.ENDED)
                {
                    _mouseButtonDown = false;
                    if(_isUpdating == false) _hintTimer.start();
                }
                else if(touch.phase == TouchPhase.MOVED && _mouseButtonDown == true)
                {
                    //새로 터치된 타일의 좌표입니다.
                    _newTileX = (touch.globalX - this.x) / GlobalData.TILE_LENGTH_SCALED;
                    _newTileY = (touch.globalY - this.y) / GlobalData.TILE_LENGTH_SCALED;
                    
                    //터치된 타일이 보드 밖에 있으면 마우스버튼 누른상태를 해제 시킵니다.
                    if(_newTileX < 0 || _newTileX >= GlobalData.FIELD_WIDTH || _newTileY < 0 || _newTileY >= GlobalData.FIELD_HEIGTH)
                    {
                        _mouseButtonDown = false;
                        _hintTimer.start();
                    }
                    else if(_currentTileX != _newTileX || _currentTileY != _newTileY)
                    {   //터치된 타일이 보드 안에 있을때
                        _mouseButtonDown = false;
                        
                        //현재 타일과(지금 터치된 new말고) 화면의 터치 좌표를 비교합니다.
                        var intervalX:Number = touch.globalX - this.x - ((_currentTileX * GlobalData.TILE_LENGTH_SCALED) + (GlobalData.TILE_LENGTH_SCALED >> 1));
                        var intervalY:Number = touch.globalY - this.y - ((_currentTileY * GlobalData.TILE_LENGTH_SCALED) + (GlobalData.TILE_LENGTH_SCALED >> 1));
                        
                        _newTileX = _currentTileX;
                        _newTileY = _currentTileY;
                        
                        //비교한 좌표를 이용하여 현재타일(new말고)의 인접한 타일이 new타일이 될수 있도록 합니다.
                        if(Math.abs(intervalX) > Math.abs(intervalY)) (intervalX > 0) ? _newTileX++ : _newTileX--;
                        else                                          (intervalY > 0) ? _newTileY++ : _newTileY--;
                        
                        if(_tiles[_newTileY][_newTileX].visible != false)
                        {
                            //두개의 타일을 swap시킵니다.
                            touchOff();
                            _tiles[_currentTileY][_currentTileX].swap(_tiles[_newTileY][_newTileX], updateBoardForSwap);
                        }
                        else
                        {
                            _hintTimer.start();
                        }
                    }
                    else _hintTimer.start();
                }
            }
        }
        
        private function updateBoardForSwap():void
        {
            _isUpdating = true;
            
            //이전 update 결과물들을 제거합니다.
            resultClear();
            
            //swap한 두 타일이 특수타일인지 확입합니다.
            if(BoardChecker.instance.checkSwapTileIsSpecialTile(_currentTileX,_currentTileY,_newTileX,_newTileY,_horizontalResult,_verticalResult,_tiles))
            {
                //특수 타일일 경우 이동횟수를 감소시키고
                _inGameStageInfo.moveNum--;
                (this.parent as InGame).updateMoveNum(_inGameStageInfo.moveNum);
                
                //이번에 제거될 타일들을 제거합니다.
                BoardRemover.instance.removeMarkTile(_horizontalResult, _verticalResult, _tiles, _inGameStageInfo);
                (this.parent as InGame).updatePoint(_inGameStageInfo.point);
                
                //빈자리로 타일들을 이동시킵니다.
                BoardTileMover.instance.moveTiles(_tiles, _inGameStageInfo, updateBoard);
            }
            else
            {
                //swap 타일들을 기준으로 가로세로 검사를 합니다.
                if(_currentTileY == _newTileY)
                {
                    BoardChecker.instance.checkHorizontal(_currentTileY, _tiles, _horizontalResult);
                    BoardChecker.instance.checkVertical(_currentTileX, _tiles, _verticalResult);
                    BoardChecker.instance.checkVertical(_newTileX, _tiles, _verticalResult);
                }
                else
                {
                    BoardChecker.instance.checkHorizontal(_currentTileY, _tiles, _horizontalResult);
                    BoardChecker.instance.checkHorizontal(_newTileY, _tiles, _horizontalResult);
                    BoardChecker.instance.checkVertical(_currentTileX, _tiles, _verticalResult);
                }
                
                //제거 할 타일들이 존재할 경우
                if(_horizontalResult.length > 0 || _verticalResult.length > 0)
                {
                    //이동횟수를 감소시키고
                    _inGameStageInfo.moveNum--;
                    (this.parent as InGame).updateMoveNum(_inGameStageInfo.moveNum);
                    
                    //이번에 제거할 타일들 중에 가로 세로 겹치는 타일이 있는지 확인합니다.
                    BoardChecker.instance.checkCross(_horizontalResult, _verticalResult, _crossResult);
                    
                    //이번에 제거될 타일들을 제거합니다.
                    BoardRemover.instance.removeMarkTile(_horizontalResult, _verticalResult, _tiles, _inGameStageInfo);
                    (this.parent as InGame).updatePoint(_inGameStageInfo.point);
                    
                    //이번 swap으로 특수 타일이 생겼을 경우 표시해줍니다.
                    BoardMarker.instance.markSpecialTileForSwap(_currentTileX, _currentTileY, _newTileX, _newTileY, _horizontalResult, _verticalResult, _crossResult, _tiles);
                    
                    //빈자리로 타일들을 이동시킵니다.
                    BoardTileMover.instance.moveTiles(_tiles, _inGameStageInfo, updateBoard);
                }
                else
                {
                    _tiles[_currentTileY][_currentTileX].swap(_tiles[_newTileY][_newTileX], touchOn);
                    _isUpdating = false;
                    _hintTimer.start();
                }
            }
        }
        
        private function updateBoard():void
        {
            _isUpdating = true;
            
            //이전 update 결과물들을 제거합니다.
            resultClear();
            
            //모든 타일들을 검사합니다.
            BoardChecker.instance.checkAll(_horizontalResult, _verticalResult, _tiles);
            
            //제거할 타일이 존재하는지 확인합니다.
            if(_horizontalResult.length > 0 || _verticalResult.length > 0)
            {
                //제거할 타일중에 가로세로 겹치는 타일이 있는지 확인합니다.
                BoardChecker.instance.checkCross(_horizontalResult, _verticalResult, _crossResult);
                
                //마크된 타일을 제거합니다.
                BoardRemover.instance.removeMarkTile(_horizontalResult, _verticalResult, _tiles, _inGameStageInfo);
                (this.parent as InGame).updatePoint(_inGameStageInfo.point);
                
                //새로 생길 특수 타일들을 만들어줍니다.
                BoardMarker.instance.markSpecialTile(_horizontalResult, _verticalResult, _crossResult, _tiles);
                
                //빈자리로 타일들을 이동시킵니다.
                BoardTileMover.instance.moveTiles(_tiles, _inGameStageInfo, updateBoard);
            }
            else
            {
                touchOn();
                
                //모든 이동횟수를 사용하였을 경우
                if(_inGameStageInfo.moveNum == 0)
                {
                    //미션타입에 따라 처리합니다. 미션타입 == 0 -> 점수로 판별하는 타입
                    if(_inGameStageInfo.missionType == 0)
                    {
                        if(_inGameStageInfo.point >= _inGameStageInfo.point1) (this.parent as InGame).missionComplete();
                        else (this.parent as InGame).missionFail();
                    }
                    else if(_inGameStageInfo.missionType == 1) (this.parent as InGame).missionFail();
                }
                
                // 아직 이동횟수가 남아있을경우 맞출 타일이 있는지 확인하면서 힌트도 미리 찾아놓습니다.
                hintCheckAndMark();
                _hintTimer.start();
                _isUpdating = false;
            }
        }
        
        /**
         * 힌트를 찾고 표시하는 함수.
         */
        private function hintCheckAndMark():void
        {
            //힌트로 표시될 타일의 인덱스가 저장되어있음.
            var hintArr:Array = BoardChecker.instance.checkHint(_tiles);
            
            //힌트가 없으면.. 즉 맞출 타일이 없으면.
            if(hintArr == null) resetTile();
            //맞출 타일이 존재하면 힌트를 sprite에 addChild 한다.
            else BoardMarker.instance.markHint(hintArr, _tiles, _hintTiles);
            
            hintArr = null;
        }
        
        /**
         * 모든 타일을 리셋하는 함수
         */
        private function resetTile():void
        {
            //모든 타일 제거
            BoardRemover.instance.removeAllTile(_tiles);
            //UI등장 및 터치 제어
            (this.parent as InGame).resetTile();
            //새로운 타일을 배치함.
            BoardTileMover.instance.moveTiles(_tiles, _inGameStageInfo, updateBoard);
        }
        
        /**
         * 보드를 검사한 결과물들을 비워줍니다.
         */
        private function resultClear():void
        {
            _horizontalResult.length = 0;
            _verticalResult.length = 0;
            _crossResult.length = 0;
        }
        
        private function hintOn(event:TimerEvent = null):void
        {
            _hintTiles.visible = true;
        }
        
        private function hintOff():void
        {
            _hintTiles.visible = false;
        }
        
        private function touchOn():void
        {
            this.touchable = true;
        }
        
        private function touchOff():void
        {
            this.touchable = false;
        }
        
        private function clear():void
        {
            if(_tiles != null)
            {
                while(_tiles.length > 0)
                {
                    _tiles[_tiles.length-1].length = 0;
                    _tiles[_tiles.length-1].pop();
                }
                _tiles = null;
            }
            if(_hintTiles != null)
            {
                while(_hintTiles.numChildren) _hintTiles.removeChildAt(0);
                _hintTiles.dispose();
                _hintTiles = null;
            }
            if(_inGameStageInfo != null)
            {
                _inGameStageInfo.clear();
                _inGameStageInfo = null;
            }
            if(_horizontalResult != null)
            {
                _horizontalResult.length = 0;
                _horizontalResult = null;
            }
            if(_verticalResult != null)
            {
                _verticalResult.length = 0;
                _verticalResult = null;
            }
            if(_crossResult != null)
            {
                _crossResult.length = 0;
                _crossResult = null;
            }
            this.removeEventListeners();
            while(this.numChildren > 0) this.removeChildAt(0);
            this.parent.removeChild(this);
            this.dispose();
        }
        
        public function get inGameStageInfo():StageInfo { return _inGameStageInfo; }
    }
}