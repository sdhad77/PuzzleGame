package N2P2.root.child
{
    import com.greensock.TweenLite;
    
    import flash.geom.Point;
    import flash.utils.ByteArray;
    
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    
    public class InGameBoard extends Sprite
    {
        private var tileTextures:Vector.<Texture>;
        
        private const INGAME_STAGE_SCALE:Number = 0.4;
        private const FIELD_WIDTH:int = 8;
        private const FIELD_HEIGTH:int = 8;
        private const TILE_TYPE:int = 6;
        private const TILE_LENGTH:int = 160;
        private const TILE_LENGTH_SCALED:Number = TILE_LENGTH * INGAME_STAGE_SCALE;
        private const TILE_GHOST:int = 24;
        
        private var _boardTileNum:Array       = new Array(FIELD_HEIGTH);
        private var _boardTileNumClone:Array  = new Array(FIELD_HEIGTH);
        private var _boardTileImage:Array     = new Array(FIELD_HEIGTH);
        private var _boardTilePos:Array       = new Array(FIELD_HEIGTH);
        private var _boardTileMinusPos:Array  = new Array(FIELD_HEIGTH);
        
        private var _mouseButtonDown:Boolean;
        
        private var _currentTileX:int;
        private var _currentTileY:int;
        private var _newTileX:int;
        private var _newTileY:int;
        
        private var _horizontalResult:Array = new Array;
        private var _verticalResult:Array = new Array;
        private var _crossResult:Array = new Array;
        
        public function InGameBoard(textureAtlas:TextureAtlas)
        {
            super();
            init(textureAtlas);
        }
        
        private function init(textureAtlas:TextureAtlas):void
        {
            tileTextures = textureAtlas.getTextures("character_");
            
            initBoardTileNum();
            initBoardTilePos();
            initBoardTileImage();
        }
        
        private function initBoardTileNum():void
        {
            var upTileNum:int;
            var leftTileNum:int;
            
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                _boardTileNum[i] = new Array(FIELD_WIDTH);
                
                for(var j:int=0; j < FIELD_WIDTH; j++)
                {
                    if(i == 0 || j == 0)
                    {
                        if(i == 0) upTileNum   = -1;
                        else       upTileNum   = _boardTileNum[i-1][j];
                        if(j == 0) leftTileNum = -1;
                        else       leftTileNum = _boardTileNum[i][j-1];
                    }
                    else
                    {
                        upTileNum = _boardTileNum[i-1][j];
                        leftTileNum = _boardTileNum[i][j-1];
                    }
                    
                    _boardTileNum[i][j] = Math.floor((Math.random())*TILE_TYPE);
                    while(_boardTileNum[i][j] == upTileNum || _boardTileNum[i][j] == leftTileNum) _boardTileNum[i][j] = Math.floor((Math.random())*TILE_TYPE);
                }
            }
        }
        
        private function initBoardTilePos():void
        {
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                _boardTilePos[i]      = new Array(FIELD_WIDTH);
                _boardTileMinusPos[i] = new Array(FIELD_WIDTH);
                
                for(var j:int=0; j < FIELD_WIDTH; j++)
                {
                    _boardTilePos[i][j]      = new Point(j * TILE_LENGTH, i * TILE_LENGTH);
                    _boardTileMinusPos[i][j] = new Point(j * TILE_LENGTH, -(i+1) * TILE_LENGTH);
                }
            }
        }
        
        private function initBoardTileImage():void
        {
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                _boardTileImage[i] = new Array(FIELD_WIDTH);
                
                for(var j:int=0; j < FIELD_WIDTH; j++)
                {
                    _boardTileImage[i][j] = new Image(tileTextures[_boardTileNum[i][j]]);
                    _boardTileImage[i][j].x = _boardTilePos[i][j].x;
                    _boardTileImage[i][j].y = _boardTilePos[i][j].y;
                    _boardTileImage[i][j].addEventListener(starling.events.TouchEvent.TOUCH, touchTile);
                    addChild(_boardTileImage[i][j]);
                }
            }
        }
        
        /**
         * 타일을 변경하는 함수.
         * @param idx1 타일 배열의 인덱스
         * @param idx2 타일 배열의 인덱스
         * @param tileNum tileNum으로 타일숫자 변경
         */
        private function changeTile(idx1:int, idx2:int, tileNum:int):void
        {
            _boardTileNum[idx1][idx2] = tileNum;
            _boardTileImage[idx1][idx2].texture = tileTextures[tileNum];
        }
        
        private function checkHorizontal(index:int, result:Array):void
        {
            var cnt:int = 0;
            var tileNum:int = _boardTileNum[index][0]%TILE_TYPE;
            
            for(var i:int=0; i < FIELD_WIDTH; i++)
            {
                if(tileNum == (_boardTileNum[index][i]%TILE_TYPE)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(index,i-cnt,cnt,true);
                    
                    cnt = 1;
                    tileNum = _boardTileNum[index][i]%TILE_TYPE;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(index,FIELD_WIDTH-cnt,cnt,true);
        }
        
        private function checkVertical(index:int, result:Array):void
        {
            var cnt:int = 0;
            var tileNum:int = _boardTileNum[0][index]%TILE_TYPE;
            
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                if(tileNum == (_boardTileNum[i][index]%TILE_TYPE)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(i-cnt,index,cnt,false);
                    
                    cnt = 1;
                    tileNum = _boardTileNum[i][index]%TILE_TYPE;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(FIELD_HEIGTH-cnt,index,cnt,false);
        }
        
        private function checkAll(horizontalArr:Array, verticalArr:Array):void
        {
            for(var i:int=0; i < FIELD_HEIGTH; i++) checkHorizontal(i, horizontalArr);
            for(i=0; i < FIELD_WIDTH; i++) checkVertical(i, verticalArr);
        }
        
        private function checkCross(horizontalArr:Array, verticalArr:Array, result:Array):void
        {
            for(var i:int=0; i<_horizontalResult.length; i++)
            {
                for(var j:int=0; j<_verticalResult.length; j++)
                {
                    _horizontalResult[i].isCross(_verticalResult[j], result);
                }
            }
        }
        
        private function checkSwapTileIsSpecialTile(horizontalArr:Array, verticalArr:Array):Boolean
        {
            var tileType1:int = _boardTileNumClone[_currentTileY][_currentTileX]/TILE_TYPE;
            var tileNum1:int  = _boardTileNumClone[_currentTileY][_currentTileX]%TILE_TYPE;
            var tileType2:int = _boardTileNumClone[_newTileY][_newTileX]/TILE_TYPE;
            var tileNum2:int  = _boardTileNumClone[_newTileY][_newTileX]%TILE_TYPE;
            
            if(tileType1 != 0 || tileType2 != 0)
            {
                if(tileType1 == 1 || tileType1 == 2)
                {
                    if(tileType2 == 1 || tileType2 == 2)
                    {
                        cross(_currentTileY, _currentTileX, _newTileY, _newTileX);
                    }
                    else if(tileType2 == 3)
                    {
                        crossX3(_currentTileY, _currentTileX);
                    }
                    else if(tileType2 == 4)
                    {
                        ghost(_currentTileY, _currentTileX, tileNum1);
                    }
                }
                else if(tileType1 == 3)
                {
                    if(tileType2 == 1 || tileType2 == 2)
                    {
                        crossX3(_newTileY, _newTileX);
                    }
                    else if(tileType2 == 3)
                    {
                        bigSunglasses(_currentTileY, _currentTileX);
                    }
                    else if(tileType2 == 4)
                    {
                        ghost(_currentTileY, _currentTileX, tileNum1);
                    }
                }
                else if(tileType1 == 4)
                {
                    if(tileType2 == 1 || tileType2 == 2)
                    {
                        ghost(_newTileY, _newTileX, tileNum2);
                    }
                    else if(tileType2 == 3)
                    {
                        ghost(_newTileY, _newTileX, tileNum2);
                    }
                    else if(tileType2 == 4)
                    {
                        trace("뭔지 모르겠다..");
                    }
                }
                else trace("swapTile 검사오류");
                
                return true;
            }
            else return false;
            
            function cross(idx1:int, idx2:int, idx3:int, idx4:int):void
            {
                _boardTileNumClone[idx1][idx2] = TILE_TYPE;
                _boardTileNumClone[idx3][idx4] = TILE_TYPE + TILE_TYPE;
                
                horizontalArr[horizontalArr.length] = new CustomVector(idx1,idx2,1,true);
                verticalArr[verticalArr.length] = new CustomVector(idx3,idx4,1,false);
            }
            function crossX3(idx1:int, idx2:int):void
            {
                var cnt:int;
                
                for(var i:int=idx1-1; i<=idx1+1; i++)
                {
                    if(i < 0) continue;
                    if(i >= FIELD_HEIGTH) break;
                    
                    cnt = i;
                    
                    for(var j:int=idx2-1; j<=idx2+1; j++)
                    {
                        if(j < 0) continue;
                        if(j >= FIELD_WIDTH) break;
                        
                        if(cnt%2 == 0)
                        {
                            _boardTileNumClone[i][j] = TILE_TYPE;
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                        else
                        {
                            _boardTileNumClone[i][j] = TILE_TYPE + TILE_TYPE;
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
                    if(i >= FIELD_HEIGTH) break;
                    
                    if(i == idx1-3 || i == idx1+3)
                    {
                        for(var j:int=idx2-2; j<=idx2+2; j++)
                        {
                            if(j < 0) continue;
                            if(j >= FIELD_WIDTH) break;
                            
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                    else
                    {
                        for(j=idx2-3; j<=idx2+3; j++)
                        {
                            if(j < 0) continue;
                            if(j >= FIELD_WIDTH) break;
                            
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                }
            }
            function ghost(idx1:int, idx2:int, tileNum:int):void
            {
                for(var i:int=0; i<FIELD_HEIGTH; i++)
                {
                    for(var j:int=0; j<FIELD_WIDTH; j++)
                    {
                        if((_boardTileNumClone[i][j]%TILE_TYPE) == tileNum)
                        {
                            _boardTileNumClone[i][j] = _boardTileNumClone[idx1][idx2];
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                }
            }
        }
        
        private function checkSwapAndBoardUpdate():void
        {
            _boardTileNumClone = clone(_boardTileNum);
            
            if(checkSwapTileIsSpecialTile(_horizontalResult, _verticalResult))
            {
                markRemoveTile(_horizontalResult, _verticalResult);
                
                var maxTweenTime:Number = moveTiles();
                TweenLite.delayedCall(maxTweenTime, boardUpdate);
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
                    checkCross(_horizontalResult, _verticalResult, _crossResult);
                    markRemoveTile(_horizontalResult, _verticalResult);
                    markSpecialTileForSwap(_horizontalResult, _verticalResult, _crossResult);
                    
                    maxTweenTime = moveTiles();
                    TweenLite.delayedCall(maxTweenTime, boardUpdate);
                }
                else
                {
                    swapTile(_currentTileX, _currentTileY, _newTileX, _newTileY, touchOn);
                }
            }
            
            resultClear();
        }
        
        private function swapTile(idx1:int, idx2:int, idx3:int, idx4:int, call:Function = null):void
        {
            var temp1:int = _boardTileNum[idx2][idx1];
            var temp2:int = _boardTileNum[idx4][idx3];
            
            changeTile(idx2, idx1, temp2);
            changeTile(idx4, idx3, temp1);
            
            TweenLite.from(_boardTileImage[idx2][idx1], 0.2, {x:_boardTilePos[idx4][idx3].x, y: _boardTilePos[idx4][idx3].y});
            TweenLite.from(_boardTileImage[idx4][idx3], 0.2, {x:_boardTilePos[idx2][idx1].x, y: _boardTilePos[idx2][idx1].y, onComplete: call});
        }
        
        private function touchTile(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if(touch != null)
            {
                if(touch.phase == TouchPhase.BEGAN)
                {
                    _mouseButtonDown = true;
                    
                    _currentTileX = (touch.globalX - this.x) / TILE_LENGTH_SCALED;
                    _currentTileY = (touch.globalY - this.y) / TILE_LENGTH_SCALED;
                }
                else if(touch.phase == TouchPhase.ENDED)
                {
                    _mouseButtonDown = false;
                }
                else if(touch.phase == TouchPhase.MOVED && _mouseButtonDown == true)
                {
                    _newTileX = (touch.globalX - this.x) / TILE_LENGTH_SCALED;
                    _newTileY = (touch.globalY - this.y) / TILE_LENGTH_SCALED;
                    
                    if(_newTileX < 0 || _newTileX >= FIELD_WIDTH || _newTileY < 0 || _newTileY >= FIELD_HEIGTH) _mouseButtonDown = false;
                    else if(_currentTileX != _newTileX || _currentTileY != _newTileY)
                    {
                        _mouseButtonDown = false;
                        touchOff();
                        
                        var intervalX:Number = touch.globalX - this.x - ((_currentTileX << 6) + (TILE_LENGTH_SCALED >> 1));
                        var intervalY:Number = touch.globalY - this.y - ((_currentTileY << 6) + (TILE_LENGTH_SCALED >> 1));
                        
                        _newTileX = _currentTileX;
                        _newTileY = _currentTileY;
                        
                        if(Math.abs(intervalX) > Math.abs(intervalY))
                        {
                            if(intervalX > 0) _newTileX++;
                            else _newTileX--;
                        }
                        else
                        {
                            if(intervalY > 0) _newTileY++;
                            else _newTileY--;
                        }
                        
                        swapTile(_currentTileX, _currentTileY, _newTileX, _newTileY, checkSwapAndBoardUpdate);
                    }
                }
            }
        }
        
        private function removeTile(idx1:int, idx2:int):void
        {
            if(_boardTileNum[idx1][idx2] != -1)
            {
                _boardTileNum[idx1][idx2] = -1;
                if(_boardTileNumClone[idx1][idx2] >= TILE_TYPE) removeSpecialTile(idx1, idx2);
            }
        }
        
        private function removeSpecialTile(idx1:int, idx2:int):void
        {
            var tileType:int = _boardTileNumClone[idx1][idx2]/TILE_TYPE;
            
            if     (tileType == 1) horizontalTile(idx1);
            else if(tileType == 2) verticalTile  (idx2);
            else if(tileType == 3) sunglassesTile(idx1, idx2);
            else if(tileType == 4) ghostTile(Math.floor((Math.random())*TILE_TYPE));
            else trace("특수타일 버그발생");
            
            function horizontalTile(idx:int):void
            {
                for(var i:int=0; i<FIELD_WIDTH; i++) removeTile(idx, i);
            }
            function verticalTile(idx:int):void
            {
                for(var i:int=0; i<FIELD_HEIGTH; i++) removeTile(i, idx);
            }
            function sunglassesTile(idx1:int, idx2:int):void
            {
                for(var i:int=idx1-2; i<=idx1+2; i++)
                {
                    if(i < 0) continue;
                    if(i >= FIELD_HEIGTH) break;
                    
                    if(i == idx1-2 || i == idx1+2)
                    {
                        for(var j:int=idx2-1; j<=idx2+1; j++)
                        {
                            if(j < 0) continue;
                            if(j >= FIELD_WIDTH) break;
                            
                            removeTile(i, j);
                        }
                    }
                    else
                    {
                        for(j=idx2-2; j<=idx2+2; j++)
                        {
                            if(j < 0) continue;
                            if(j >= FIELD_WIDTH) break;
                            
                            removeTile(i,j);
                        }
                    }
                }
            }
            function ghostTile(tileNum:int):void
            {
                for(var i:int=0; i<FIELD_HEIGTH; i++)
                {
                    for(var j:int=0; j<FIELD_WIDTH; j++)
                    {
                        if((_boardTileNumClone[i][j]%TILE_TYPE) == tileNum) removeTile(i,j);
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
                    changeTile(horizontalArr[i].x, horizontalArr[i].y, TILE_GHOST);
                }
                else if(horizontalArr[i].length == 4)
                {
                    changeTile(horizontalArr[i].x, horizontalArr[i].y, _boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y]%TILE_TYPE + TILE_TYPE);
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                if(verticalArr[i].length >= 5)
                {
                    changeTile(verticalArr[i].x, verticalArr[i].y, TILE_GHOST);
                }
                else if(verticalArr[i].length == 4)
                {
                    changeTile(verticalArr[i].x, verticalArr[i].y, _boardTileNumClone[verticalArr[i].x][verticalArr[i].y]%TILE_TYPE + TILE_TYPE + TILE_TYPE);
                }
            }
            
            for(i=0; i<crossResult.length; i++)
            {
                changeTile(crossResult[i].x, crossResult[i].y, _boardTileNumClone[crossResult[i].x][crossResult[i].y]%TILE_TYPE + TILE_TYPE + TILE_TYPE + TILE_TYPE);
            }
        }
        
        private function markSpecialTileForSwap(horizontalArr:Array, verticalArr:Array, crossResult:Array):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                if(horizontalArr[i].length >= 5)
                {
                    if(horizontalArr[i].isExist(_currentTileY, _currentTileX)) changeTile(_currentTileY, _currentTileX, TILE_GHOST);
                    else if(horizontalArr[i].isExist(_newTileY, _newTileX)) changeTile(_newTileY, _newTileX, TILE_GHOST);
                    else changeTile(horizontalArr[i].x, horizontalArr[i].y, TILE_GHOST);
                }
                else if(horizontalArr[i].length == 4)
                {
                    if(horizontalArr[i].isExist(_currentTileY, _currentTileX)) changeTile(_currentTileY, _currentTileX, _boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y]%TILE_TYPE + TILE_TYPE);
                    else if(horizontalArr[i].isExist(_newTileY, _newTileX)) changeTile(_newTileY, _newTileX, _boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y]%TILE_TYPE + TILE_TYPE);
                    else changeTile(horizontalArr[i].x, horizontalArr[i].y, _boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y]%TILE_TYPE + TILE_TYPE);
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                if(verticalArr[i].length >= 5)
                {
                    if(verticalArr[i].isExist(_currentTileY, _currentTileX)) changeTile(_currentTileY, _currentTileX, TILE_GHOST);
                    else if(verticalArr[i].isExist(_newTileY, _newTileX)) changeTile(_newTileY, _newTileX, TILE_GHOST);
                    else changeTile(verticalArr[i].x, verticalArr[i].y, TILE_GHOST);
                }
                else if(verticalArr[i].length == 4)
                {
                    if(verticalArr[i].isExist(_currentTileY, _currentTileX)) changeTile(_currentTileY, _currentTileX, _boardTileNumClone[verticalArr[i].x][verticalArr[i].y]%TILE_TYPE + TILE_TYPE + TILE_TYPE);
                    else if(verticalArr[i].isExist(_newTileY, _newTileX)) changeTile(_newTileY, _newTileX, _boardTileNumClone[verticalArr[i].x][verticalArr[i].y]%TILE_TYPE + TILE_TYPE + TILE_TYPE);
                    else changeTile(verticalArr[i].x, verticalArr[i].y, _boardTileNumClone[verticalArr[i].x][verticalArr[i].y]%TILE_TYPE + TILE_TYPE + TILE_TYPE);
                }
            }
            
            for(i=0; i<crossResult.length; i++)
            {
                changeTile(crossResult[i].x, crossResult[i].y, _boardTileNumClone[crossResult[i].x][crossResult[i].y]%TILE_TYPE + TILE_TYPE + TILE_TYPE + TILE_TYPE);
            }
        }
        
        private function moveTiles():Number
        {
            var isUpTileExist:Boolean;
            var minusLineIdx:int;
            var maxTweenTime:Number=-1;
            
            for(var i:int=0; i < FIELD_WIDTH; i++)
            {
                minusLineIdx = 0;
                
                for(var j:int=FIELD_HEIGTH-1; 0 <= j; j--)
                {
                    isUpTileExist = false;
                    
                    if(_boardTileNum[j][i] == -1)
                    {
                        for(var q:int=j; 0 <= q; q--)
                        {
                            if(_boardTileNum[q][i] != -1)
                            {
                                changeTile(j, i, _boardTileNum[q][i]);
                                TweenLite.from(_boardTileImage[j][i], 0.2*(j-q), {y: _boardTilePos[q][i].y});
                                if(maxTweenTime < 0.2*(j-q)) maxTweenTime = 0.2*(j-q);
                                _boardTileNum[q][i] = -1;
                                isUpTileExist = true;
                                break;
                            }
                        }
                        if(!isUpTileExist)
                        {
                            changeTile(j, i, Math.floor((Math.random())*TILE_TYPE));
                            TweenLite.from(_boardTileImage[j][i], 0.2*(minusLineIdx+j+1), {y: _boardTileMinusPos[minusLineIdx][i].y});
                            if(maxTweenTime < 0.2*(minusLineIdx+j+1)) maxTweenTime = 0.2*(minusLineIdx+j+1);
                            minusLineIdx++;
                        }
                    }
                }
            }
            
            return maxTweenTime;
        }
        
        private function boardUpdate():void
        {
            _boardTileNumClone = clone(_boardTileNum);
            
            checkAll(_horizontalResult, _verticalResult);
            
            if(_horizontalResult.length > 0 || _verticalResult.length > 0)
            {
                checkCross(_horizontalResult, _verticalResult, _crossResult);
                markRemoveTile(_horizontalResult, _verticalResult);
                markSpecialTile(_horizontalResult, _verticalResult, _crossResult);
                
                var maxTweenTime:Number = moveTiles();
                
                TweenLite.delayedCall(maxTweenTime, boardUpdate);
            }
            else touchOn();
            
            resultClear();
        }
        
        private function resultClear():void
        {
            _horizontalResult.length = 0;
            _verticalResult.length = 0;
            _crossResult.length = 0;
            _boardTileNumClone.length = 0;
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
            tileTextures.length = 0;
            tileTextures = null;
            _boardTileNum.length = 0;
            _boardTileNum = null;
            _boardTileImage.length = 0;
            _boardTileImage = null;
            _boardTilePos.length = 0;
            _boardTilePos = null;
            _boardTileMinusPos.length = 0;
            _boardTileMinusPos = null;
            this.removeEventListeners();
            while(this.numChildren > 0) this.removeChildAt(0);
            this.parent.removeChild(this);
            this.dispose();
        }
        
        private function clone(source:Object):* 
        { 
            var myBA:ByteArray = new ByteArray(); 
            myBA.writeObject(source); 
            myBA.position = 0; 
            return(myBA.readObject()); 
        }
    }
}

import flash.geom.Point;

class CustomVector
{
    private var _x:int;
    private var _y:int;
    private var _length:int
    private var _isHorizontal:Boolean;
    
    public function CustomVector(x:int, y:int, length:int, isHorizontal:Boolean)
    {
        _x = x;
        _y = y;
        _length = length;
        _isHorizontal = isHorizontal;
    }
    
    public function isCross(v1:CustomVector, result:Array):void
    {
        if(v1.x <= this.x && this.x <= (v1.x + v1.length -1) && this.y <= v1.y && v1.y <= (this.y + this.length -1)) result[result.length] = new Point(this.x, v1.y);
    }
    
    public function isExist(idx1:int, idx2:int):Boolean
    {
        if(_isHorizontal == true)
        {
            if(_x == idx1)
            {
                for(var i:int=0; i<_length; i++)
                {
                    if((y+i) == idx2) return true;
                }
            }
            else return false;
        }
        else
        {
            if(_y == idx2)
            {
                for(i=0; i<_length; i++)
                {
                    if((x+i) == idx1) return true;
                }
            }
            else return false;
        }
        
        return false;
    }
    
    public function get x():int                { return _x;            }
    public function get y():int                { return _y;            }
    public function get length():int           { return _length;       }
    public function get isHorizontal():Boolean { return _isHorizontal; }
}