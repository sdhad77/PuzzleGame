package N2P2.root.child.ingame.utils
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Linear;
    
    import flash.utils.getTimer;
    
    import N2P2.utils.GlobalData;
    
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;
    import N2P2.root.child.ingame.InGame;
    
    public class Board extends Sprite
    {
        private var _tiles:Vector.<Vector.<Tile>> = new Vector.<Vector.<Tile>>;
        private var _inGameStageInfo:StageInfo = new StageInfo;
        private var _hintTiles:Sprite = new Sprite;
        
        private var _checker:BoardChecker = new BoardChecker;
        private var _marker:BoardMarker = new BoardMarker;
        private var _remover:BoardRemover = new BoardRemover;
        private var _mover:BoardTileMover = new BoardTileMover;
        
        private var _mouseButtonDown:Boolean;
        private var _lastTileMoveTime:Number;
        
        private var _currentTileX:int;
        private var _currentTileY:int;
        private var _newTileX:int;
        private var _newTileY:int;
        
        private var _horizontalResult:Array = new Array;
        private var _verticalResult:Array = new Array;
        private var _crossResult:Array = new Array;
        
        public function Board(stageNum:Number, assetManager:AssetManager)
        {
            super();
            
            init(stageNum, assetManager);
        }
        
        private function init(stageNum:Number, assetManager:AssetManager):void
        {
            TweenLite.defaultEase = Linear.easeNone;
            _lastTileMoveTime = getTimer();
            
            loadGameStage(stageNum, assetManager);
            initTiles();
            initHintTiles();
            
            var hintArr:Array = _checker.checkHint(_tiles);
            if(hintArr == null)
            {
                _remover.removeAllTile(_tiles);
                (this.parent as InGame).resetTile();
                _mover.moveTiles(_tiles, _inGameStageInfo, boardUpdate);
            }
            else
            {
                _marker.markHint(hintArr, _tiles, _hintTiles);
                hintArr = null;
            }
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
        }
        
        private function loadGameStage(stageNum:Number, assetManager:AssetManager):void
        {
            _inGameStageInfo.parseStageInfoXml(assetManager.getXml("stageInfo"), stageNum);
        }
        
        private function initTiles():void
        {
            var upTileNum:int;
            var leftTileNum:int;
            var tileNum:int;
            
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++)
            {
                _tiles.push(new Vector.<Tile>);
                
                for(var j:int=0; j < GlobalData.FIELD_WIDTH; j++)
                {
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
                    
                    tileNum = Math.floor((Math.random())*GlobalData.TILE_CHAR);
                    while(tileNum == upTileNum || tileNum == leftTileNum) tileNum = Math.floor((Math.random())*GlobalData.TILE_CHAR);
                    
                    _tiles[i].push(new Tile(tileNum));
                    _tiles[i][j].x = j * GlobalData.TILE_LENGTH;
                    _tiles[i][j].y = i * GlobalData.TILE_LENGTH;
                    _tiles[i][j].addEventListener(starling.events.TouchEvent.TOUCH, touchTile);
                    addChild(_tiles[i][j]);
                    
                    if(_inGameStageInfo.board[i][j] == 1) _tiles[i][j].visibleOff();
                }
            }
        }
        
        private function initHintTiles():void
        {
            _hintTiles.touchable = false;
            _hintTiles.visible = false;
            addChild(_hintTiles);
        }
        
        private function enterFrame():void
        {
            if(this.touchable == true && _mouseButtonDown == false && getTimer() - _lastTileMoveTime >= 3000)
            {
                _lastTileMoveTime = getTimer();
                hintOn();
            }
        }
        
        private function touchTile(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if(touch != null)
            {
                if(touch.phase == TouchPhase.BEGAN)
                {
                    _mouseButtonDown = true;
                    
                    _currentTileX = (touch.globalX - this.x) / GlobalData.TILE_LENGTH_SCALED;
                    _currentTileY = (touch.globalY - this.y) / GlobalData.TILE_LENGTH_SCALED;
                    
                    _lastTileMoveTime = getTimer();
                    hintOff();
                }
                else if(touch.phase == TouchPhase.ENDED)
                {
                    _mouseButtonDown = false;
                }
                else if(touch.phase == TouchPhase.MOVED && _mouseButtonDown == true)
                {
                    _newTileX = (touch.globalX - this.x) / GlobalData.TILE_LENGTH_SCALED;
                    _newTileY = (touch.globalY - this.y) / GlobalData.TILE_LENGTH_SCALED;
                    
                    if(_newTileX < 0 || _newTileX >= GlobalData.FIELD_WIDTH || _newTileY < 0 || _newTileY >= GlobalData.FIELD_HEIGTH) _mouseButtonDown = false;
                    else if(_currentTileX != _newTileX || _currentTileY != _newTileY)
                    {
                        _mouseButtonDown = false;
                        
                        var intervalX:Number = touch.globalX - this.x - ((_currentTileX << 6) + (GlobalData.TILE_LENGTH_SCALED >> 1));
                        var intervalY:Number = touch.globalY - this.y - ((_currentTileY << 6) + (GlobalData.TILE_LENGTH_SCALED >> 1));
                        
                        _newTileX = _currentTileX;
                        _newTileY = _currentTileY;
                        
                        if(Math.abs(intervalX) > Math.abs(intervalY)) (intervalX > 0) ? _newTileX++ : _newTileX--;
                        else                                          (intervalY > 0) ? _newTileY++ : _newTileY--;
                        
                        if(_tiles[_newTileY][_newTileX].visible != false)
                        {
                            touchOff();
                            _tiles[_currentTileY][_currentTileX].swap(_tiles[_newTileY][_newTileX], boardUpdateForSwap);
                        }
                    }
                }
            }
        }
        
        private function boardUpdateForSwap():void
        {
            resultClear();
            
            if(_checker.checkSwapTileIsSpecialTile(_currentTileX,_currentTileY,_newTileX,_newTileY,_horizontalResult,_verticalResult,_tiles))
            {
                _inGameStageInfo.moveNum--;
                (this.parent as InGame).updateMoveNum(_inGameStageInfo.moveNum);
                _remover.removeMarkTile(_horizontalResult, _verticalResult, _tiles, _inGameStageInfo);
                (this.parent as InGame).updatePoint(_inGameStageInfo.point);
                _mover.moveTiles(_tiles, _inGameStageInfo, boardUpdate);
            }
            else
            {
                if(_currentTileY == _newTileY)
                {
                    _checker.checkHorizontal(_currentTileY, _tiles, _horizontalResult);
                    _checker.checkVertical(_currentTileX, _tiles, _verticalResult);
                    _checker.checkVertical(_newTileX, _tiles, _verticalResult);
                }
                else
                {
                    _checker.checkHorizontal(_currentTileY, _tiles, _horizontalResult);
                    _checker.checkHorizontal(_newTileY, _tiles, _horizontalResult);
                    _checker.checkVertical(_currentTileX, _tiles, _verticalResult);
                }
                
                if(_horizontalResult.length > 0 || _verticalResult.length > 0)
                {
                    _inGameStageInfo.moveNum--;
                    (this.parent as InGame).updateMoveNum(_inGameStageInfo.moveNum);
                    _checker.checkCross(_horizontalResult, _verticalResult, _crossResult);
                    _remover.removeMarkTile(_horizontalResult, _verticalResult, _tiles, _inGameStageInfo);
                    (this.parent as InGame).updatePoint(_inGameStageInfo.point);
                    _marker.markSpecialTileForSwap(_currentTileX, _currentTileY, _newTileX, _newTileY, _horizontalResult, _verticalResult, _crossResult, _tiles);
                    _mover.moveTiles(_tiles, _inGameStageInfo, boardUpdate);
                }
                else
                {
                    _tiles[_currentTileY][_currentTileX].swap(_tiles[_newTileY][_newTileX], touchOn);
                }
            }
        }
        
        private function boardUpdate():void
        {
            resultClear();
            
            _checker.checkAll(_horizontalResult, _verticalResult, _tiles);
            
            if(_horizontalResult.length > 0 || _verticalResult.length > 0)
            {
                _checker.checkCross(_horizontalResult, _verticalResult, _crossResult);
                _remover.removeMarkTile(_horizontalResult, _verticalResult, _tiles, _inGameStageInfo);
                (this.parent as InGame).updatePoint(_inGameStageInfo.point);
                _marker.markSpecialTile(_horizontalResult, _verticalResult, _crossResult, _tiles);
                _mover.moveTiles(_tiles, _inGameStageInfo, boardUpdate);
            }
            else
            {
                _lastTileMoveTime = getTimer();
                touchOn();
                if(_inGameStageInfo.moveNum == 0)
                {
                    if(_inGameStageInfo.missionType == 0)
                    {
                        if(_inGameStageInfo.point >= _inGameStageInfo.point1) (this.parent as InGame).missionComplete();
                        else (this.parent as InGame).missionFail();
                    }
                    else if(_inGameStageInfo.missionType == 1) (this.parent as InGame).missionFail();
                }
                
                var hintArr:Array = _checker.checkHint(_tiles);
                if(hintArr == null)
                {
                    _remover.removeAllTile(_tiles);
                    (this.parent as InGame).resetTile();
                    _mover.moveTiles(_tiles, _inGameStageInfo, boardUpdate);
                }
                else
                {
                    _marker.markHint(hintArr, _tiles, _hintTiles);
                    hintArr = null;
                }
            }
        }
        
        private function resultClear():void
        {
            _horizontalResult.length = 0;
            _verticalResult.length = 0;
            _crossResult.length = 0;
        }
        
        private function hintOn():void
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
            _checker = null;
            _marker = null;
            _remover = null;
            _mover = null;
            this.removeEventListeners();
            while(this.numChildren > 0) this.removeChildAt(0);
            this.parent.removeChild(this);
            this.dispose();
        }
        
        public function get inGameStageInfo():StageInfo { return _inGameStageInfo; }
    }
}