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
        private var tileArr:Array = new Array("null","ani_0.png","ari_0.png","blue_0.png","heart_0.png","lucy_0.png","micky_0.png","mongyi_0.png","pinky_0.png");
        private var gameArray:Array = new Array(FIELDSIZE * FIELDSIZE);
        
        private var _mouseButtonDown:Boolean;
        
        private var _currentTileIdx:int;
        
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
            var j:int = 0;
            
            for(var i:int=0; i < FIELDSIZE*FIELDSIZE; i++) gameArray[i] = new TileInfo(Math.ceil((Math.random())*TILETYPE));
            
            for(i=0; i<FIELDSIZE*FIELDSIZE; i++)
            {
                gameArray[i].img = new Image(assetManager.getTextureAtlas("char2").getTexture(tileArr[gameArray[i].tileNum]));
                gameArray[i].img.x = (i - j*FIELDSIZE) * gameArray[i].img.width;
                gameArray[i].img.y = j * gameArray[i].img.height;
                gameArray[i].img.addEventListener(starling.events.TouchEvent.TOUCH, clicked);
                addChild(gameArray[i].img);
                
                if(i%FIELDSIZE == FIELDSIZE-1) j++;
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
                    
                    _currentTileIdx = (touch.globalX>>6) + ((touch.globalY>>6)*FIELDSIZE);
                }
                else if(touch.phase == TouchPhase.ENDED)
                {
                    _mouseButtonDown = false;
                }
                else if(touch.phase == TouchPhase.MOVED && _mouseButtonDown == true)
                {
                    var newTileX:int = touch.globalX>>6;
                    var newTileY:int = touch.globalY>>6;
                    var newTileIdx:int = newTileX + newTileY*FIELDSIZE;
                    
                    if(newTileX < 0 || newTileX >= FIELDSIZE || newTileY < 0 || newTileY >= FIELDSIZE)
                    {
                        _mouseButtonDown = false;
                    }
                    else if(_currentTileIdx != newTileIdx)
                    {
                        var currentTile:TileInfo = gameArray[_currentTileIdx];
                        var newTile:TileInfo = gameArray[newTileIdx];
                        
                        if(Math.abs(_currentTileIdx - newTileIdx) == 1)
                        {
                            TweenLite.to(currentTile.img, 0.5, {x:currentTile.img.x + newTile.img.x - currentTile.img.x, onComplete:resetTouch});
                            TweenLite.to(newTile.img, 0.5, {x:newTile.img.x + currentTile.img.x - newTile.img.x, onComplete:resetTouch});
                        }
                        else
                        {
                            TweenLite.to(currentTile.img, 0.5, {y:currentTile.img.y + newTile.img.y - currentTile.img.y, onComplete:resetTouch});
                            TweenLite.to(newTile.img, 0.5, {y:newTile.img.y + currentTile.img.y - newTile.img.y, onComplete:resetTouch});
                        }
                        
                        gameArray[_currentTileIdx] = newTile;
                        gameArray[newTileIdx] = currentTile;
                        
                        currentTile = null;
                        newTile = null;
                        
                        _mouseButtonDown = false;
                        this.touchable = false;
                    }
                }
            }
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
        
        private function resetTouch():void
        {
            this.touchable = true;
        }
        
        private function clear():void
        {
            while(tileArr.length > 0) tileArr.pop();
            tileArr = null;
            while(gameArray.length > 0)
            {
                gameArray[gameArray.length-1].img = null;
                gameArray.pop();
            }
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