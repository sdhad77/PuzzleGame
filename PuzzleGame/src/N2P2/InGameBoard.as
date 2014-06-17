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
        
        private var boardTileNum:Array       = new Array(FIELD_HEIGTH);
        private var boardTileNumClone:Array  = new Array(FIELD_HEIGTH);
        private var boardTileImage:Array     = new Array(FIELD_HEIGTH);
        private var boardTilePos:Array       = new Array(FIELD_HEIGTH);
        private var boardTileMinusPos:Array  = new Array(FIELD_HEIGTH);
        
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
                boardTileNum[i] = new Array(FIELD_WIDTH);
                
                for(var j:int=0; j < FIELD_WIDTH; j++)
                {
                    if(i == 0 || j == 0)
                    {
                        if(i == 0) upTileNum   = -1;
                        else       upTileNum   = boardTileNum[i-1][j];
                        if(j == 0) leftTileNum = -1;
                        else       leftTileNum = boardTileNum[i][j-1];
                    }
                    else
                    {
                        upTileNum = boardTileNum[i-1][j];
                        leftTileNum = boardTileNum[i][j-1];
                    }
                    
                    boardTileNum[i][j] = Math.floor((Math.random())*TILE_TYPE);
 //                   while(boardTileNum[i][j] == upTileNum || boardTileNum[i][j] == leftTileNum) boardTileNum[i][j] = Math.floor((Math.random())*TILE_TYPE);
                }
            }
        }
        
        private function initBoardTilePos():void
        {
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                boardTilePos[i]      = new Array(FIELD_WIDTH);
                boardTileMinusPos[i] = new Array(FIELD_WIDTH);
                
                for(var j:int=0; j < FIELD_WIDTH; j++)
                {
                    boardTilePos[i][j]      = new Point(j * TILE_LENGTH, i * TILE_LENGTH);
                    boardTileMinusPos[i][j] = new Point(j * TILE_LENGTH, -(i+1) * TILE_LENGTH);
                }
            }
        }
        
        private function initBoardTileImage():void
        {
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                boardTileImage[i] = new Array(FIELD_WIDTH);
                
                for(var j:int=0; j < FIELD_WIDTH; j++)
                {
                    boardTileImage[i][j] = new Image(tileTextures[boardTileNum[i][j]]);
                    boardTileImage[i][j].x = boardTilePos[i][j].x;
                    boardTileImage[i][j].y = boardTilePos[i][j].y;
                    boardTileImage[i][j].addEventListener(starling.events.TouchEvent.TOUCH, tileTouch);
                    addChild(boardTileImage[i][j]);
                }
            }
        }
        
        private function checkHorizontal(index:int, result:Array):Boolean
        {
            var cnt:int = 0;
            var tileNum:int = boardTileNum[index][0]%TILE_TYPE;
            var resultLength:int = result.length;
            
            for(var i:int=0; i < FIELD_WIDTH; i++)
            {
                if(i == 0 && boardTileNum[index][0] == TILE_GHOST)
                {
                    cnt++;
                    tileNum = boardTileNum[index][i+1];
                }
                else if(boardTileNum[index][i] == TILE_GHOST || tileNum == (boardTileNum[index][i]%TILE_TYPE)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(index,i-cnt,cnt);
                    
                    cnt = 1;
                    tileNum = boardTileNum[index][i];
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(index,FIELD_WIDTH-cnt,cnt);
            
            if(resultLength != result.length) return true;
            else return false;
        }
        
        private function checkVertical(index:int, result:Array):Boolean
        {
            var cnt:int = 0;
            var tileNum:int = boardTileNum[0][index]%TILE_TYPE;
            var resultLength:int = result.length;
            
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                if(i == 0 && boardTileNum[0][index] == TILE_GHOST)
                {
                    cnt++;
                    tileNum = boardTileNum[i+1][index];
                }
                else if(boardTileNum[i][index] == TILE_GHOST || tileNum == (boardTileNum[i][index]%TILE_TYPE)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(i-cnt,index,cnt);
                    
                    cnt = 1;
                    tileNum = boardTileNum[i][index];
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(FIELD_HEIGTH-cnt,index,cnt);
            
            if(resultLength != result.length) return true;
            else return false;
        }
        
        private function checkAll(horizontalArr:Array, verticalArr:Array):Boolean
        {
            var cnt:int;
            var tileNum:int;
            var result:Boolean = false;
            
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                if(checkHorizontal(i, horizontalArr)) result = true;
            }
            
            for(i=0; i < FIELD_WIDTH; i++)
            {
                if(checkVertical(i, verticalArr)) result = true;
            }
            
            return result;
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
        
        private function tileSwap(idx1:int, idx2:int, idx3:int, idx4:int, call:Function = null):void
        {
            var temp:int = boardTileNum[idx2][idx1];
            boardTileNum[idx2][idx1] = boardTileNum[idx4][idx3];
            boardTileNum[idx4][idx3] = temp;
            
            boardTileImage[idx2][idx1].texture = tileTextures[boardTileNum[idx2][idx1]];
            boardTileImage[idx4][idx3].texture = tileTextures[boardTileNum[idx4][idx3]];
            
            TweenLite.from(boardTileImage[idx2][idx1], 0.2, {x:boardTilePos[idx4][idx3].x, y: boardTilePos[idx4][idx3].y});
            TweenLite.from(boardTileImage[idx4][idx3], 0.2, {x:boardTilePos[idx2][idx1].x, y: boardTilePos[idx2][idx1].y, onComplete: call});
        }
        
        private function tileTouch(event:TouchEvent):void
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
                        
                        tileSwap(_currentTileX, _currentTileY, _newTileX, _newTileY, tileSwapComplete);
                    }
                }
            }
        }
        
        private function tileSwapComplete():void
        {
            if(_currentTileY == _newTileY)
            {
                checkHorizontal(_currentTileY, _horizontalResult);
                checkVertical(_currentTileX, _verticalResult);
                checkVertical(_newTileX, _verticalResult);
            }
            else
            {
                checkHorizontal(_currentTileY, _horizontalResult);
                checkHorizontal(_newTileY, _horizontalResult);
                checkVertical(_currentTileX, _verticalResult);
            }
            
            if(_horizontalResult.length > 0 || _verticalResult.length > 0) boardUpdate();
            else tileSwap(_currentTileX, _currentTileY, _newTileX, _newTileY, touchOn);
        }
        
        private function crashTileMark():void
        {
            var offset:int;
            var tileType:int;
            
            for(var i:int=0; i<_horizontalResult.length; i++)
            {
                offset = 0;
                
                while(offset < _horizontalResult[i].length)
                {
                    tileType = boardTileNumClone[_horizontalResult[i].x][_horizontalResult[i].y + offset]/TILE_TYPE;
                    
                    if     (tileType == 0) defaultTile(_horizontalResult[i].x, _horizontalResult[i].y + offset);
                    else if(tileType == 1) horizontalTile(_horizontalResult[i].x);
                    else if(tileType == 2) verticalTile(_horizontalResult[i].y + offset);
                    else if(tileType == 3) defaultTile(_horizontalResult[i].x, _horizontalResult[i].y + offset);
                    else if(tileType == 4) defaultTile(_horizontalResult[i].x, _horizontalResult[i].y + offset);
                    
                    offset++;
                }
            }
            
            for(i=0; i<_verticalResult.length; i++)
            {
                offset = 0;
                
                while(offset < _verticalResult[i].length)
                {
                    tileType = boardTileNumClone[_verticalResult[i].x + offset][_verticalResult[i].y]/TILE_TYPE;
                    
                    if     (tileType == 0) defaultTile(_verticalResult[i].x + offset, _verticalResult[i].y);
                    else if(tileType == 1) horizontalTile(_verticalResult[i].x + offset);
                    else if(tileType == 2) verticalTile(_verticalResult[i].y);
                    else if(tileType == 3) boardTileNum[_verticalResult[i].x + offset][_verticalResult[i].y] = -1;
                    else if(tileType == 4) boardTileNum[_verticalResult[i].x + offset][_verticalResult[i].y] = -1;
                    
                    offset++;
                }
            }
            
            function defaultTile(idx1:int, idx2:int):void
            {
                boardTileNum[idx1][idx2] = -1;
            }
            function horizontalTile(idx:int):void
            {
                for(var j:int=0; j<FIELD_WIDTH; j++) boardTileNum[idx][j] = -1;
            }
            function verticalTile(idx:int):void
            {
                for(var j:int=0; j<FIELD_HEIGTH; j++) boardTileNum[j][idx] = -1;
            }
            function sunglassesTile(idx1:int, idx2:int):void
            {
                
            }
            function ghostTile():void
            {
                
            }
        }
        
        private function crossTileMark():void
        {
            for(var i:int=0; i<_crossResult.length; i++)
            {
                boardTileNum[_crossResult[i].x][_crossResult[i].y] = boardTileNumClone[_crossResult[i].x][_crossResult[i].y] + TILE_TYPE + TILE_TYPE + TILE_TYPE;
                boardTileImage[_crossResult[i].x][_crossResult[i].y].texture = tileTextures[boardTileNum[_crossResult[i].x][_crossResult[i].y]];
            }
        }
        
        private function lineTileMark():void
        {
            for(var i:int=0; i<_horizontalResult.length; i++)
            {
                if(_horizontalResult[i].length >= 5) boardTileNum[_horizontalResult[i].x][_horizontalResult[i].y] = 24;
                else if(_horizontalResult[i].length == 4) boardTileNum[_horizontalResult[i].x][_horizontalResult[i].y] = boardTileNumClone[_horizontalResult[i].x][_horizontalResult[i].y] + TILE_TYPE;
            }
            
            for(i=0; i<_verticalResult.length; i++)
            {
                if(_verticalResult[i].length >= 5) boardTileNum[_verticalResult[i].x][_verticalResult[i].y] = 24;
                else if(_verticalResult[i].length == 4) boardTileNum[_verticalResult[i].x][_verticalResult[i].y] = boardTileNumClone[_verticalResult[i].x][_verticalResult[i].y] + TILE_TYPE + TILE_TYPE;
            }
        }
        
        private function boardUpdate():void
        {
            var isUpTileExist:Boolean;
            var minusLineIdx:int;
            var maxTweenTime:Number=-1;
            
            boardTileNumClone = clone(boardTileNum);
            checkCross(_horizontalResult, _verticalResult, _crossResult);
            crashTileMark();
            crossTileMark();
            lineTileMark();
            
            for(var i:int=0; i < FIELD_WIDTH; i++)
            {
                minusLineIdx = 0;
                
                for(var j:int=FIELD_HEIGTH-1; 0 <= j; j--)
                {
                    isUpTileExist = false;
                    
                    if(boardTileNum[j][i] == -1)
                    {
                        for(var q:int=j; 0 <= q; q--)
                        {
                            if(boardTileNum[q][i] != -1)
                            {
                                boardTileNum[j][i] = boardTileNum[q][i];
                                boardTileImage[j][i].texture = tileTextures[boardTileNum[j][i]];
                                TweenLite.from(boardTileImage[j][i], 0.2*(j-q), {y: boardTilePos[q][i].y});
                                if(maxTweenTime < 0.2*(j-q)) maxTweenTime = 0.2*(j-q);
                                boardTileNum[q][i] = -1;
                                isUpTileExist = true;
                                break;
                            }
                        }
                        if(!isUpTileExist)
                        {
                            boardTileNum[j][i] = Math.floor((Math.random())*TILE_TYPE);
                            boardTileImage[j][i].texture = tileTextures[boardTileNum[j][i]];
                            TweenLite.from(boardTileImage[j][i], 0.2*(minusLineIdx+j+1), {y: boardTileMinusPos[minusLineIdx][i].y});
                            if(maxTweenTime < 0.2*(minusLineIdx+j+1)) maxTweenTime = 0.2*(minusLineIdx+j+1);
                            minusLineIdx++;
                        }
                    }
                }
            }
            
            resultClear();
            TweenLite.delayedCall(maxTweenTime, boardUpdateComplete);
        }
        
        private function boardUpdateComplete():void
        {
            touchOff();
            
            if(checkAll(_horizontalResult, _verticalResult))
            {
                boardUpdate();
            }
            else touchOn();
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
            tileTextures.length = 0;
            tileTextures = null;
            boardTileNum.length = 0;
            boardTileNum = null;
            boardTileImage.length = 0;
            boardTileImage = null;
            boardTilePos.length = 0;
            boardTilePos = null;
            boardTileMinusPos.length = 0;
            boardTileMinusPos = null;
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