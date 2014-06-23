package N2P2.root.child
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Linear;
    
    import N2P2.utils.CustomVector;
    import N2P2.utils.GlobalData;
    import N2P2.utils.InGameStageInfo;
    import N2P2.utils.Tile;
    
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;
    
    public class InGameBoard extends Sprite
    {
        private var _tiles:Vector.<Vector.<Tile>> = new Vector.<Vector.<Tile>>;
        private var _inGameStageInfo:InGameStageInfo = new InGameStageInfo;
        
        private var _mouseButtonDown:Boolean;
        
        private var _currentTileX:int;
        private var _currentTileY:int;
        private var _newTileX:int;
        private var _newTileY:int;
        
        private var _horizontalResult:Array = new Array;
        private var _verticalResult:Array = new Array;
        private var _crossResult:Array = new Array;
        
        public function InGameBoard(stageNum:Number, assetManager:AssetManager)
        {
            super();
            
            init(stageNum, assetManager);
        }
        
        private function init(stageNum:Number, assetManager:AssetManager):void
        {
            TweenLite.defaultEase = Linear.easeNone;
            
            loadGameStage(stageNum, assetManager);
            initTiles();
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
        
        private function checkHorizontal(index:int, result:Array):void
        {
            var cnt:int = 0;
            var tileChar:int = _tiles[index][0].char;
            
            for(var i:int=0; i < GlobalData.FIELD_WIDTH; i++)
            {
                if(_tiles[index][i].visible == true && tileChar == (_tiles[index][i].char)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(index,i-cnt,cnt,true);
                    
                    cnt = 1;
                    tileChar = _tiles[index][i].char;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(index,GlobalData.FIELD_WIDTH-cnt,cnt,true);
        }
        
        private function checkVertical(index:int, result:Array):void
        {
            var cnt:int = 0;
            var tileChar:int = _tiles[0][index].char;
            
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++)
            {
                if(_tiles[i][index].visible == true && tileChar == (_tiles[i][index].char)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(i-cnt,index,cnt,false);
                    
                    cnt = 1;
                    tileChar = _tiles[i][index].char;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(GlobalData.FIELD_HEIGTH-cnt,index,cnt,false);
        }
        
        private function checkAll(horizontalArr:Array, verticalArr:Array):void
        {
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++) checkHorizontal(i, horizontalArr);
            for(i=0; i < GlobalData.FIELD_WIDTH; i++) checkVertical(i, verticalArr);
        }
        
        private function checkCross(horizontalArr:Array, verticalArr:Array, result:Array):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                for(var j:int=0; j<verticalArr.length; j++)
                {
                    horizontalArr[i].isCross(verticalArr[j], result);
                }
            }
        }
        
        private function checkSwapTileIsSpecialTile(horizontalArr:Array, verticalArr:Array):Boolean
        {
            var tileType1:int = _tiles[_currentTileY][_currentTileX].type;
            var tileChar1:int  = _tiles[_currentTileY][_currentTileX].char;
            var tileType2:int = _tiles[_newTileY][_newTileX].type;
            var tileChar2:int  = _tiles[_newTileY][_newTileX].char;
            
            if(tileType1 == 0 && tileType2 == 4) ghost(_currentTileY, _currentTileX, tileChar1);
            if(tileType1 == 1 || tileType1 == 2)
            {
                if     (tileType2 == 1) cross(_currentTileY, _currentTileX, _newTileY, _newTileX);
                else if(tileType2 == 2) cross(_currentTileY, _currentTileX, _newTileY, _newTileX);
                else if(tileType2 == 3) crossX3(_currentTileY, _currentTileX);
                else if(tileType2 == 4) ghost(_currentTileY, _currentTileX, tileChar1);
                else return false;
            }
            else if(tileType1 == 3)
            {
                if     (tileType2 == 1) crossX3(_newTileY, _newTileX);
                else if(tileType2 == 2) crossX3(_newTileY, _newTileX);
                else if(tileType2 == 3) bigSunglasses(_currentTileY, _currentTileX);
                else if(tileType2 == 4) ghost(_currentTileY, _currentTileX, tileChar1);
                else return false;
            }
            else if(tileType1 == 4)
            {
                ghost(_newTileY, _newTileX, tileChar2);
            }
            else return false;
                
            return true;
            
            function cross(idx1:int, idx2:int, idx3:int, idx4:int):void
            {
                _tiles[idx1][idx2].changeType(GlobalData.TILE_TYPE_HORIZONTAL);
                _tiles[idx3][idx4].changeType(GlobalData.TILE_TYPE_VERTICAL);
                
                horizontalArr[horizontalArr.length] = new CustomVector(idx1,idx2,1,true);
                verticalArr[verticalArr.length] = new CustomVector(idx3,idx4,1,false);
            }
            function crossX3(idx1:int, idx2:int):void
            {
                var cnt:int;
                
                for(var i:int=idx1-1; i<=idx1+1; i++)
                {
                    if(i < 0) continue;
                    if(i >= GlobalData.FIELD_HEIGTH) break;
                    
                    cnt = i;
                    
                    for(var j:int=idx2-1; j<=idx2+1; j++)
                    {
                        if(j < 0) continue;
                        if(j >= GlobalData.FIELD_WIDTH) break;
                        
                        if(cnt%2 == 0)
                        {
                            _tiles[i][j].changeType(GlobalData.TILE_TYPE_HORIZONTAL);
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                        else
                        {
                            _tiles[i][j].changeType(GlobalData.TILE_TYPE_VERTICAL);
                            verticalArr[verticalArr.length] = new CustomVector(i,j,1,false);
                        }
                        
                        cnt++;
                    }
                }
            }
            function bigSunglasses(idx1:int, idx2:int):void
            {
                for(var i:int=idx1-3; i<=idx1+3; i++)
                {
                    if(i < 0) continue;
                    if(i >= GlobalData.FIELD_HEIGTH) break;
                    
                    if(i == idx1-3 || i == idx1+3)
                    {
                        for(var j:int=idx2-2; j<=idx2+2; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                    else
                    {
                        for(j=idx2-3; j<=idx2+3; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                }
            }
            function ghost(idx1:int, idx2:int, tileChar:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
                {
                    for(var j:int=0; j<GlobalData.FIELD_WIDTH; j++)
                    {
                        if((_tiles[i][j].char) == tileChar)
                        {
                            _tiles[i][j].change(_tiles[idx1][idx2].num);
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                }
            }
        }
        
        private function checkSwapAndBoardUpdate():void
        {
            resultClear();
            
            if(checkSwapTileIsSpecialTile(_horizontalResult, _verticalResult))
            {
                _inGameStageInfo.moveNum--;
                markRemoveTile(_horizontalResult, _verticalResult);
                moveTiles();
            }
            else
            {
                if(_currentTileY == _newTileY)
                {
                    checkHorizontal(_currentTileY, _horizontalResult);
                    checkVertical(_currentTileX,_verticalResult);
                    checkVertical(_newTileX, _verticalResult);
                }
                else
                {
                    checkHorizontal(_currentTileY, _horizontalResult);
                    checkHorizontal(_newTileY, _horizontalResult);
                    checkVertical(_currentTileX,_verticalResult);
                }
                
                if(_horizontalResult.length > 0 || _verticalResult.length > 0)
                {
                    _inGameStageInfo.moveNum--;
                    checkCross(_horizontalResult, _verticalResult, _crossResult);
                    markRemoveTile(_horizontalResult, _verticalResult);
                    markSpecialTileForSwap(_horizontalResult, _verticalResult, _crossResult);
                    moveTiles();
                }
                else
                {
                    _tiles[_currentTileY][_currentTileX].swap(_tiles[_newTileY][_newTileX], touchOn);
                }
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
                            _tiles[_currentTileY][_currentTileX].swap(_tiles[_newTileY][_newTileX], checkSwapAndBoardUpdate);
                        }
                    }
                }
            }
        }
        
        private function removeTile(idx1:int, idx2:int):void
        {
            if(_tiles[idx1][idx2].vanishFromBoard()) removeSpecialTile(idx1, idx2);
        }
        
        private function removeSpecialTile(idx1:int, idx2:int):void
        {
            var tileType:int = _tiles[idx1][idx2].type;
            
            if     (tileType == 1) horizontalTile(idx1);
            else if(tileType == 2) verticalTile  (idx2);
            else if(tileType == 3) sunglassesTile(idx1, idx2);
            else if(tileType == 4) ghostTile(Math.floor((Math.random())*GlobalData.TILE_CHAR));
            else trace("특수타일 버그발생");
            
            function horizontalTile(idx:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_WIDTH; i++) removeTile(idx, i);
            }
            function verticalTile(idx:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++) removeTile(i, idx);
            }
            function sunglassesTile(idx1:int, idx2:int):void
            {
                for(var i:int=idx1-2; i<=idx1+2; i++)
                {
                    if(i < 0) continue;
                    if(i >= GlobalData.FIELD_HEIGTH) break;
                    
                    if(i == idx1-2 || i == idx1+2)
                    {
                        for(var j:int=idx2-1; j<=idx2+1; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            removeTile(i, j);
                        }
                    }
                    else
                    {
                        for(j=idx2-2; j<=idx2+2; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            removeTile(i,j);
                        }
                    }
                }
            }
            function ghostTile(tileChar:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
                {
                    for(var j:int=0; j<GlobalData.FIELD_WIDTH; j++)
                    {
                        if((_tiles[i][j].char) == tileChar) removeTile(i,j);
                    }
                }
            }
        }
        
        private function markRemoveTile(horizontalArr:Array, verticalArr:Array):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                for(var offset:int=0; offset < horizontalArr[i].length; offset++)
                {
                    removeTile(horizontalArr[i].x, horizontalArr[i].y + offset);
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                for(offset=0; offset < verticalArr[i].length; offset++)
                {
                    removeTile(verticalArr[i].x + offset, verticalArr[i].y);
                }
            }
        }
        
        private function markSpecialTile(horizontalArr:Array, verticalArr:Array, crossResult:Array):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                if(horizontalArr[i].length >= 5)
                {
                    _tiles[horizontalArr[i].x][horizontalArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(horizontalArr[i].length == 4)
                {
                    _tiles[horizontalArr[i].x][horizontalArr[i].y].mark(_tiles[horizontalArr[i].x][horizontalArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                if(verticalArr[i].length >= 5)
                {
                    _tiles[verticalArr[i].x][verticalArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(verticalArr[i].length == 4)
                {
                    _tiles[verticalArr[i].x][verticalArr[i].y].mark(_tiles[verticalArr[i].x][verticalArr[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<crossResult.length; i++)
            {
                _tiles[crossResult[i].x][crossResult[i].y].mark(_tiles[crossResult[i].x][crossResult[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
            }
        }
        
        private function markSpecialTileForSwap(hArr:Array, vArr:Array, cArr:Array):void
        {
            for(var i:int=0; i<hArr.length; i++)
            {
                if(hArr[i].length >= 5)
                {
                    if(hArr[i].isExist(_currentTileY, _currentTileX)) _tiles[_currentTileY][_currentTileX].mark(GlobalData.TILE_GHOST);
                    else if(hArr[i].isExist(_newTileY, _newTileX)) _tiles[_newTileY][_newTileX].mark(GlobalData.TILE_GHOST);
                    else _tiles[hArr[i].x][hArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(hArr[i].length == 4)
                {
                    if(hArr[i].isExist(_currentTileY, _currentTileX)) _tiles[_currentTileY][_currentTileX].mark(_tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                    else if(hArr[i].isExist(_newTileY, _newTileX)) _tiles[_newTileY][_newTileX].mark(_tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                    else _tiles[hArr[i].x][hArr[i].y].mark(_tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<vArr.length; i++)
            {
                if(vArr[i].length >= 5)
                {
                    if(vArr[i].isExist(_currentTileY, _currentTileX)) _tiles[_currentTileY][_currentTileX].mark(GlobalData.TILE_GHOST);
                    else if(vArr[i].isExist(_newTileY, _newTileX)) _tiles[_newTileY][_newTileX].mark(GlobalData.TILE_GHOST);
                    else _tiles[vArr[i].x][vArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(vArr[i].length == 4)
                {
                    if(vArr[i].isExist(_currentTileY, _currentTileX)) _tiles[_currentTileY][_currentTileX].mark(_tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                    else if(vArr[i].isExist(_newTileY, _newTileX)) _tiles[_newTileY][_newTileX].mark(_tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                    else _tiles[vArr[i].x][vArr[i].y].mark(_tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<cArr.length; i++)
            {
                _tiles[cArr[i].x][cArr[i].y].mark(_tiles[cArr[i].x][cArr[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
            }
        }
        
        private function moveTiles():void
        {
            var moveTileExist:Boolean = false;
            
            for(var j:int=GlobalData.FIELD_HEIGTH-1; 0 <= j; j--)
            {
                for(var i:int=0; i < GlobalData.FIELD_WIDTH; i++)
                {
                    if(_tiles[j][i].visible == false && _inGameStageInfo.board[j][i] == 0)
                    {
                        if(j == 0)
                        {
                            _tiles[j][i].mark(Math.floor((Math.random())*GlobalData.TILE_CHAR));
                            _tiles[j][i].moveFrom(null, "-160");
                            moveTileExist = true;
                        }
                        else
                        {
                            if(_tiles[j-1][i].visible == true)
                            {
                                _tiles[j][i].mark(_tiles[j-1][i].num);
                                _tiles[j][i].moveFrom(null, "-160");
                                _tiles[j-1][i].visible = false;
                            }
                            else if(_inGameStageInfo.boardForMove[j][i] == 1)
                            {
                                if(i != 0 && _tiles[j-1][i-1].visible == true && _tiles[j][i-1].visible == true)
                                {
                                    _tiles[j][i].mark(_tiles[j-1][i-1].num);
                                    _tiles[j][i].moveFrom("-160", "-160");
                                    _tiles[j-1][i-1].visible = false;
                                }
                                else if(i != (GlobalData.FIELD_WIDTH-1) && _tiles[j-1][i+1].visible == true && _tiles[j][i+1].visible == true)
                                {
                                    _tiles[j][i].mark(_tiles[j-1][i+1].num);
                                    _tiles[j][i].moveFrom("160", "-160");
                                    _tiles[j-1][i+1].visible = false;
                                }
                                else continue;
                            }
                            else continue;
                            
                            moveTileExist = true;
                        }
                    }
                }
            }
            
            if(moveTileExist == true) TweenLite.delayedCall(GlobalData.TWEEN_TIME, moveTiles);
            else boardUpdate();
        }
        
        private function boardUpdate():void
        {
            resultClear();
            
            checkAll(_horizontalResult, _verticalResult);
            
            if(_horizontalResult.length > 0 || _verticalResult.length > 0)
            {
                checkCross(_horizontalResult, _verticalResult, _crossResult);
                markRemoveTile(_horizontalResult, _verticalResult);
                markSpecialTile(_horizontalResult, _verticalResult, _crossResult);
                moveTiles();
            }
            else
            {
                touchOn();
                trace(_inGameStageInfo.moveNum, this.parent);
                if(_inGameStageInfo.moveNum == 0)
                {
                    trace("game over");
                    (this.parent as InGame).missionComplete();
                }
            }
        }
        
        private function resultClear():void
        {
            _horizontalResult.length = 0;
            _verticalResult.length = 0;
            _crossResult.length = 0;
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
    }
}