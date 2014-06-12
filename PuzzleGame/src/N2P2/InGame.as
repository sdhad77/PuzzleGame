package N2P2 
{
    import com.greensock.TweenLite;
    
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;

    public class InGame extends Sprite
    {
        private const FIELDSIZE:int = 8;
        private const TILETYPE:int = 8;
        private var tileArr:Array = new Array("ani_0.png","ari_0.png","blue_0.png","heart_0.png","lucy_0.png","micky_0.png","mongyi_0.png","pinky_0.png");
        private var tileTextureArr:Array = new Array(TILETYPE);
        private var gameArray:Array = new Array(FIELDSIZE);
        
        private var _mouseButtonDown:Boolean;
        private var _tileChecking:Boolean;
        
        private var _currentTileX:int;
        private var _currentTileY:int;
        private var _newTileX:int;
        private var _newTileY:int;
        
        public function InGame()
        {
            super();
        }
        
        public function start(assetManager:AssetManager, stageNum:Number):void
        {
            drawGame(assetManager, stageNum);
        }
        
        private function drawGame(assetManager:AssetManager, stageNum:Number):void
        {
            for(var i:int=0; i < TILETYPE; i++) tileTextureArr[i] = assetManager.getTextureAtlas("char2").getTexture(tileArr[i]);
            for(i=0; i < FIELDSIZE; i++) gameArray[i] = new Array(FIELDSIZE);
            for(i=0; i < FIELDSIZE; i++)
            {
                for(var j:int=0; j < FIELDSIZE; j++)
                {
                    gameArray[i][j] = new TileInfo(Math.floor((Math.random())*TILETYPE));
                    
                    if(i != 0 && j != 0)
                    {
                        while(gameArray[i][j].tileNum == gameArray[i][j-1].tileNum && gameArray[i][j].tileNum == gameArray[i-1][j].tileNum)
                        {
                            gameArray[i][j].tileNum = Math.floor((Math.random())*TILETYPE);
                        }
                    }
                    else if(i != 0) while(gameArray[i][j].tileNum == gameArray[i-1][j].tileNum) gameArray[i][j].tileNum = Math.floor((Math.random())*TILETYPE);
                    else if(j != 0) while(gameArray[i][j].tileNum == gameArray[i][j-1].tileNum) gameArray[i][j].tileNum = Math.floor((Math.random())*TILETYPE);
                    
                    gameArray[i][j].img = new Image(tileTextureArr[gameArray[i][j].tileNum]);
                    gameArray[i][j].img.x = j * gameArray[i][j].img.width;
                    gameArray[i][j].img.y = i * gameArray[i][j].img.height;
                    gameArray[i][j].img.addEventListener(starling.events.TouchEvent.TOUCH, clicked);
                    addChild(gameArray[i][j].img);
                }
            }
            
            addChild(new Image(assetManager.getTextureAtlas("char2").getTexture("heart_0.png")));
            this.getChildAt(this.numChildren-1).x = 550;
            this.getChildAt(this.numChildren-1).y = 550;
            this.getChildAt(this.numChildren-1).addEventListener(starling.events.TouchEvent.TOUCH, returnWorldMap);
        }
        
        private function clicked(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if(touch != null)
            {
                if(touch.phase == TouchPhase.BEGAN)
                {
                    _mouseButtonDown = true;
                    
                    _currentTileX = touch.globalX >> 6;
                    _currentTileY = touch.globalY >> 6;
                }
                else if(touch.phase == TouchPhase.ENDED)
                {
                    _mouseButtonDown = false;
                }
                else if(touch.phase == TouchPhase.MOVED && _mouseButtonDown == true)
                {
                    _newTileX = touch.globalX >> 6;
                    _newTileY = touch.globalY >> 6;
                    
                    if(_newTileX < 0 || _newTileX >= FIELDSIZE || _newTileY < 0 || _newTileY >= FIELDSIZE)
                    {
                        _mouseButtonDown = false;
                        return;
                    }

                    if(_currentTileX != _newTileX || _currentTileY != _newTileY)
                    {
                        _mouseButtonDown = false;
                        this.touchable = false;
                        
                        _tileChecking = true;
                        touchTileChange(_currentTileX, _currentTileY, _newTileX, _newTileY);
                    }
                }
            }
        }
        
        private function touchTileChange(idx1:int, idx2:int, idx3:int, idx4:int):void
        {
            var tile1:TileInfo = gameArray[idx2][idx1];
            var tile2:TileInfo = gameArray[idx4][idx3];
            
            if((Math.abs(idx1 - idx3) == 1 && Math.abs(idx2 - idx4) == 1))
            {
                trace("버그");
                this.touchable = true;
                _tileChecking = false;
                return;
            }
            else if(Math.abs(idx1 - idx3) == 1)
            {
                TweenLite.to(tile1.img, 0.1, {x:tile2.img.x});
                TweenLite.to(tile2.img, 0.1, {x:tile1.img.x, onComplete:touchTileChangeComplete});
            }
            else if(Math.abs(idx2 - idx4) == 1)
            {
                TweenLite.to(tile1.img, 0.1, {y:tile2.img.y});
                TweenLite.to(tile2.img, 0.1, {y:tile1.img.y, onComplete:touchTileChangeComplete});
            }
            
            gameArray[idx2][idx1] = tile2;
            gameArray[idx4][idx3] = tile1;
            
            tile1 = null;
            tile2 = null;
        }
        
        private function touchTileChangeComplete():void
        {
            if(_tileChecking)
            {
                _tileChecking = false;
                
                if(!tileListCheck([_currentTileY, _currentTileX, _newTileY, _newTileX]))
                {
                    touchTileChange(_currentTileX, _currentTileY, _newTileX, _newTileY);
                }
                else this.touchable = true;
            }
            else this.touchable = true;
        }
        
        private function tileListCheck(tileList:Array):Boolean
        {
            var result:Boolean = false;
            
            for(var i:int=0; i<tileList.length; i+=2)
            {
                if(tileCheck(tileList[i], tileList[i+1])) result = true;
            }
            
            tileList.length = 0;
            tileList = null;
            
            return result;
        }
        
        private function tileCheck(i:int, j:int):Boolean
        {
            var up:int    = i-1 != -1        ? i-1 : -1;
            var down:int  = i+1 != FIELDSIZE ? i+1 : -1;
            var left:int  = j-1 != -1        ? j-1 : -1;
            var right:int = j+1 != FIELDSIZE ? j+1 : -1;
            
            var horizontalArr:Array = new Array(i,j);
            var verticalArr:Array = new Array(i,j);
            
            if(up    != -1 && gameArray[i][j].tileNum == gameArray[up][j].tileNum)    tileCheck2(up,    j, 0, verticalArr);
            if(down  != -1 && gameArray[i][j].tileNum == gameArray[down][j].tileNum)  tileCheck2(down,  j, 1, verticalArr);
            if(left  != -1 && gameArray[i][j].tileNum == gameArray[i][left].tileNum)  tileCheck2(i,  left, 2, horizontalArr);
            if(right != -1 && gameArray[i][j].tileNum == gameArray[i][right].tileNum) tileCheck2(i, right, 3, horizontalArr);
            
            var result:Boolean = tileRemove(horizontalArr, verticalArr);
            
            horizontalArr.length = 0;
            horizontalArr = null;
            verticalArr.length = 0;
            verticalArr = null;
            
            return result;
        }
        
        private function tileCheck2(i:int, j:int, direction:int, resultArr:Array):Array
        {
            var targetIdxI:int = i;
            var targetIdxJ:int = j;
            
            if     (direction == 0) targetIdxI = (i-1) != -1 ? i-1 : -1;
            else if(direction == 1) targetIdxI = (i+1) != FIELDSIZE ? i+1 : -1;
            else if(direction == 2) targetIdxJ = (j-1) != -1 ? j-1 : -1;
            else                    targetIdxJ = (j+1) != FIELDSIZE ? j+1 : -1;
            
            resultArr[resultArr.length] = i;
            resultArr[resultArr.length] = j;
            
            if(targetIdxI != -1 && targetIdxJ != -1 && gameArray[i][j].tileNum == gameArray[targetIdxI][targetIdxJ].tileNum)
            {
                tileCheck2(targetIdxI, targetIdxJ, direction, resultArr);
            }
            
            return resultArr;
        }
        
        private function tileRemove(horizontalArr:Array, verticalArr:Array):Boolean
        {
            var idxI:int;
            var idxJ:int;
            var tempTile:TileInfo;
            var tempTileArr:Array;
            
            if(verticalArr.length >= 6)
            {
                var minIdxI:int = 100;
                var minIdxI2:int;
                var maxIdxI:int = -1;
                
                tempTileArr = new Array(verticalArr.length >> 1);
                
                for(var i:int=0; i<verticalArr.length; i+=2)
                {
                    idxI = verticalArr[i];
                    idxJ = verticalArr[i+1];
                    
                    if(idxI < minIdxI) minIdxI = idxI;
                    if(idxI > maxIdxI) maxIdxI = idxI;
                    
                    tempTileArr[i>>1] = gameArray[idxI][idxJ];
                }
                
                minIdxI2 = minIdxI;
                    
                while(minIdxI-1 >= 0)
                {
                    gameArray[minIdxI+tempTileArr.length-1][idxJ] = gameArray[minIdxI-1][idxJ];
                    TweenLite.to(gameArray[minIdxI+tempTileArr.length-1][idxJ].img, 0.3*tempTileArr.length, {y:(tempTileArr.length << 6).toString()});
                    minIdxI--;
                }
                
                for(i=0; i<verticalArr.length; i+=2)
                {
                    idxI = verticalArr[i];
                    idxJ = verticalArr[i+1];
                    
                    tempTileArr[i>>1].img.y -= 64*(maxIdxI+1);
                    tempTileArr[i>>1].tileNum = Math.floor((Math.random())*TILETYPE);
                    tempTileArr[i>>1].img.texture = tileTextureArr[tempTileArr[i>>1].tileNum];
                    
                    gameArray[idxI-minIdxI2][idxJ] = tempTileArr[i>>1];
                    TweenLite.to(gameArray[idxI-minIdxI2][idxJ].img, 0.3*tempTileArr.length, {y:(tempTileArr.length << 6).toString()});
                }
                
                tempTileArr.length = 0;
                tempTileArr = null;
                
                return true;
            }
            else if(horizontalArr.length >= 6)
            {
                for(i=0; i<horizontalArr.length; i+=2)
                {
                    idxI = horizontalArr[i];
                    idxJ = horizontalArr[i+1];
                 
                    gameArray[idxI][idxJ].tileNum = Math.floor((Math.random())*TILETYPE);
                    gameArray[idxI][idxJ].img.y = -64;
                    gameArray[idxI][idxJ].img.texture = tileTextureArr[gameArray[idxI][idxJ].tileNum];
                    tempTile = gameArray[idxI][idxJ];
                    
                    while(idxI-1 >= 0)
                    {
                        gameArray[idxI][idxJ] = gameArray[idxI-1][idxJ];
                        TweenLite.to(gameArray[idxI][idxJ].img, 0.3, {y:"64"});
                        idxI--;
                    }
                    
                    gameArray[0][idxJ] = tempTile;
                    TweenLite.to(gameArray[0][idxJ].img, 0.3, {y:"64"});
                }

                tempTile = null;
                
                return true;
            }
            
            return false;
        }
        
        private function returnWorldMap(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null)
            {
                (this.root as Game).startWorldMap();
                clear();
            }
        }
        
        private function clear():void
        {
            tileArr.length = 0;
            tileArr = null;
            tileTextureArr.length = 0;
            tileTextureArr = null;
            for(var i:int=0; i<gameArray.length; i++) gameArray[i].img = null;
            gameArray.length = 0;
            gameArray = null;
            this.removeEventListeners();
            while(this.numChildren > 0) this.removeChildAt(0);
            this.parent.removeChild(this);
            this.dispose();
        }
    }
}

import starling.display.Image;

class TileInfo
{
    private var _tileNum:int;
    private var _img:Image;
    
    public function TileInfo(tileNum:int)
    {
        _tileNum = tileNum;
    }
    
    public function get tileNum():int { return _tileNum; }
    public function get img():Image   { return _img;     }
    
    public function set tileNum(value:int):void { _tileNum = value; }
    public function set img(value:Image):void   { _img     = value; }
}