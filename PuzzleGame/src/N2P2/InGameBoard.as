package N2P2
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
        private var _tileSwap:Boolean;
        
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
            _tileSwap = false;
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
        
        private function checkHorizontal(index:int, result:Array):void
        {
            var cnt:int = 0;
            var tileNum:int = _boardTileNum[index][0]%TILE_TYPE;
            
            for(var i:int=0; i < FIELD_WIDTH; i++)
            {
                if(i == 0 && _boardTileNum[index][0] == TILE_GHOST)
                {
                    cnt++;
                    tileNum = _boardTileNum[index][i+1]%TILE_TYPE;
                }
                else if(_boardTileNum[index][i] == TILE_GHOST || tileNum == (_boardTileNum[index][i]%TILE_TYPE)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(index,i-cnt,cnt);
                    
                    cnt = 1;
                    tileNum = _boardTileNum[index][i]%TILE_TYPE;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(index,FIELD_WIDTH-cnt,cnt);
        }
        
        private function checkVertical(index:int, result:Array):void
        {
            var cnt:int = 0;
            var tileNum:int = _boardTileNum[0][index]%TILE_TYPE;
            
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                if(i == 0 && _boardTileNum[0][index] == TILE_GHOST)
                {
                    cnt++;
                    tileNum = _boardTileNum[i+1][index]%TILE_TYPE;
                }
                else if(_boardTileNum[i][index] == TILE_GHOST || tileNum == (_boardTileNum[i][index]%TILE_TYPE)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(i-cnt,index,cnt);
                    
                    cnt = 1;
                    tileNum = _boardTileNum[i][index]%TILE_TYPE;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(FIELD_HEIGTH-cnt,index,cnt);
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
        
        private function checkSwap():void
        {
            if(_tileSwap)
            {
                _tileSwap = false;
                
                //검사 코드 추가
            }
        }
        
        private function swapTile(idx1:int, idx2:int, idx3:int, idx4:int, call:Function = null):void
        {
            var temp:int = _boardTileNum[idx2][idx1];
            _boardTileNum[idx2][idx1] = _boardTileNum[idx4][idx3];
            _boardTileNum[idx4][idx3] = temp;
            
            _boardTileImage[idx2][idx1].texture = tileTextures[_boardTileNum[idx2][idx1]];
            _boardTileImage[idx4][idx3].texture = tileTextures[_boardTileNum[idx4][idx3]];
            
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
                        
                        _tileSwap = true;
                        swapTile(_currentTileX, _currentTileY, _newTileX, _newTileY, boardUpdate);
                    }
                }
            }
        }
        
        private function markCrashTile(horizontalArr:Array, verticalArr:Array):void
        {
            var offset:int;
            var tileType:int;
            
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                offset = 0;
                
                while(offset < horizontalArr[i].length)
                {
                    tileType = _boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y + offset]/TILE_TYPE;
                    
                    if     (tileType == 0) defaultTile   (horizontalArr[i].x, horizontalArr[i].y + offset);
                    else if(tileType == 1) horizontalTile(horizontalArr[i].x);
                    else if(tileType == 2) verticalTile  (horizontalArr[i].y + offset);
                    else if(tileType == 3) sunglassesTile(horizontalArr[i].x, horizontalArr[i].y + offset);
                    else if(tileType == 4 && offset == 0) ghostTile(_boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y + offset+1]%TILE_TYPE);
                    else if(tileType == 4 && offset != 0) ghostTile(_boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y + offset-1]%TILE_TYPE);
                    
                    offset++;
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                offset = 0;
                
                while(offset < verticalArr[i].length)
                {
                    tileType = _boardTileNumClone[verticalArr[i].x + offset][verticalArr[i].y]/TILE_TYPE;
                    
                    if     (tileType == 0) defaultTile   (verticalArr[i].x + offset, verticalArr[i].y);
                    else if(tileType == 1) horizontalTile(verticalArr[i].x + offset);
                    else if(tileType == 2) verticalTile  (verticalArr[i].y);
                    else if(tileType == 3) sunglassesTile(verticalArr[i].x + offset, verticalArr[i].y);
                    else if(tileType == 4 && offset == 0) ghostTile(_boardTileNumClone[verticalArr[i].x + offset+1][verticalArr[i].y]%TILE_TYPE);
                    else if(tileType == 4 && offset != 0) ghostTile(_boardTileNumClone[verticalArr[i].x + offset-1][verticalArr[i].y]%TILE_TYPE);
                    
                    offset++;
                }
            }
            
            function defaultTile(idx1:int, idx2:int):void
            {
                _boardTileNum[idx1][idx2] = -1;
            }
            function horizontalTile(idx:int):void
            {
                for(var j:int=0; j<FIELD_WIDTH; j++) _boardTileNum[idx][j] = -1;
            }
            function verticalTile(idx:int):void
            {
                for(var j:int=0; j<FIELD_HEIGTH; j++) _boardTileNum[j][idx] = -1;
            }
            function sunglassesTile(idx1:int, idx2:int):void
            {
                for(var j:int=idx1-2; j<=idx1+2; j++)
                {
                    if(j < 0) continue;
                    if(j >= FIELD_HEIGTH) break;
                    
                    if(j == idx1-2 || j == idx1+2)
                    {
                        for(var k:int=idx2-1; k<=idx2+1; k++)
                        {
                            if(k < 0) continue;
                            if(k >= FIELD_WIDTH) break;
                            
                            _boardTileNum[j][k] = -1;
                        }
                    }
                    else
                    {
                        for(k=idx2-2; k<=idx2+2; k++)
                        {
                            if(k < 0) continue;
                            if(k >= FIELD_WIDTH) break;
                            
                            _boardTileNum[j][k] = -1;
                        }
                    }
                }
            }
            function ghostTile(tileNum:int):void
            {
                for(var j:int=0; j<FIELD_HEIGTH; j++)
                {
                    for(var k:int=0; k<FIELD_WIDTH; k++)
                    {
                        if((_boardTileNumClone[j][k]%TILE_TYPE) == tileNum) _boardTileNum[j][k] = -1;
                    }
                }
            }
        }
        
        private function markCrossTile(crossResult:Array):void
        {
            for(var i:int=0; i<crossResult.length; i++)
            {
                _boardTileNum[crossResult[i].x][crossResult[i].y] = _boardTileNumClone[crossResult[i].x][crossResult[i].y] + TILE_TYPE + TILE_TYPE + TILE_TYPE;
                _boardTileImage[crossResult[i].x][crossResult[i].y].texture = tileTextures[_boardTileNum[crossResult[i].x][crossResult[i].y]];
            }
        }
        
        private function markSpecialTile(horizontalArr:Array, verticalArr:Array):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                if(horizontalArr[i].length >= 5)
                {
                    _boardTileNum[horizontalArr[i].x][horizontalArr[i].y] = 24;
                    _boardTileImage[horizontalArr[i].x][horizontalArr[i].y].texture = tileTextures[_boardTileNum[horizontalArr[i].x][horizontalArr[i].y]];
                }
                else if(horizontalArr[i].length == 4)
                {
                    _boardTileNum[horizontalArr[i].x][horizontalArr[i].y] = _boardTileNumClone[horizontalArr[i].x][horizontalArr[i].y] + TILE_TYPE;
                    _boardTileImage[horizontalArr[i].x][horizontalArr[i].y].texture = tileTextures[_boardTileNum[horizontalArr[i].x][horizontalArr[i].y]];
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                if(verticalArr[i].length >= 5)
                {
                    _boardTileNum[verticalArr[i].x][verticalArr[i].y] = 24;
                    _boardTileImage[verticalArr[i].x][verticalArr[i].y].texture = tileTextures[_boardTileNum[verticalArr[i].x][verticalArr[i].y]];
                }
                else if(verticalArr[i].length == 4)
                {
                    _boardTileNum[verticalArr[i].x][verticalArr[i].y] = _boardTileNumClone[verticalArr[i].x][verticalArr[i].y] + TILE_TYPE + TILE_TYPE;
                    _boardTileImage[verticalArr[i].x][verticalArr[i].y].texture = tileTextures[_boardTileNum[verticalArr[i].x][verticalArr[i].y]];
                }
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
                                _boardTileNum[j][i] = _boardTileNum[q][i];
                                _boardTileImage[j][i].texture = tileTextures[_boardTileNum[j][i]];
                                TweenLite.from(_boardTileImage[j][i], 0.2*(j-q), {y: _boardTilePos[q][i].y});
                                if(maxTweenTime < 0.2*(j-q)) maxTweenTime = 0.2*(j-q);
                                _boardTileNum[q][i] = -1;
                                isUpTileExist = true;
                                break;
                            }
                        }
                        if(!isUpTileExist)
                        {
                            _boardTileNum[j][i] = Math.floor((Math.random())*TILE_TYPE);
                            _boardTileImage[j][i].texture = tileTextures[_boardTileNum[j][i]];
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
            checkCross(_horizontalResult, _verticalResult, _crossResult);
            markCrashTile(_horizontalResult, _verticalResult);
            markCrossTile(_crossResult);
            markSpecialTile(_horizontalResult, _verticalResult);
            
            if(_horizontalResult.length > 0 || _verticalResult.length > 0 || _crossResult.length > 0)
            {
                _tileSwap = false;
                
                var maxTweenTime:Number = moveTiles();
                
                TweenLite.delayedCall(maxTweenTime, boardUpdate);
            }
            else
            {
                if(_tileSwap == true)
                {
                    _tileSwap = false;
                    swapTile(_currentTileX, _currentTileY, _newTileX, _newTileY, touchOn);
                }
                else
                {
                    _tileSwap = false;
                    touchOn();
                }
            }
            
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
    
    public function CustomVector(x:int, y:int, length:int)
    {
        _x = x;
        _y = y;
        _length = length;
    }
    
    public function isCross(v1:CustomVector, result:Array):void
    {
        if(v1.x <= this.x && this.x <= (v1.x + v1.length -1) && this.y <= v1.y && v1.y <= (this.y + this.length -1)) result[result.length] = new Point(this.x, v1.y);
    }
    
    public function get x():int     {return _x;}
    public function get y():int     {return _y;}
    public function get length():int {return _length;}
}