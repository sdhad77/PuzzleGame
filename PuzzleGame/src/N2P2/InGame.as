package N2P2 
{
    import com.greensock.TweenLite;
    
    import flash.geom.Point;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.display.UserInterface;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;

    public class InGame extends Sprite
    {
        private var tileArr:Array = new Array(TILE_TOTAL);
        private var tileTextures:Array = new Array(TILE_TYPE);
        
        private const INGAME_STAGE_SCALE:Number = 0.4;
        private const FIELD_WIDTH:int = 8;
        private const FIELD_HEIGTH:int = 8;
        private const TILE_TYPE:int = 6;
        private const TILE_TOTAL:int = 19;
        private const TILE_LENGTH:int = 160;
        private const TILE_LENGTH_SCALED:Number = TILE_LENGTH * INGAME_STAGE_SCALE;
        
        private var _inGameStage:Sprite;
        private var _inGameUI:UserInterface;
        
        private var stageTileNum:Array       = new Array(FIELD_HEIGTH);
        private var stageTileImage:Array     = new Array(FIELD_HEIGTH);
        private var stageTilePos:Array       = new Array(FIELD_HEIGTH);
        private var stageTileMinusPos:Array  = new Array(FIELD_HEIGTH);
        
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
            loadStageInfo(stageNum);
            init(assetManager);
        }
        
        private function loadStageInfo(stageNum:Number):void
        {
            
        }
        
        private function init(assetManager:AssetManager):void
        {
            _inGameUI = new UserInterface(assetManager.getTextureAtlas("inGameUI"), "inGameUI_");
            _inGameUI.addTouchEventByName("inGameUI_2.png", returnWorldMap);
            addChild(_inGameUI);
            
            _inGameStage = new Sprite;
            _inGameStage.scaleX = _inGameStage.scaleY = INGAME_STAGE_SCALE;
            _inGameStage.x = (Starling.current.viewPort.width >> 1) - ((FIELD_WIDTH * TILE_LENGTH_SCALED) >> 1);
            _inGameStage.y = (Starling.current.viewPort.height >> 1) - ((FIELD_HEIGTH * TILE_LENGTH_SCALED) >> 1);
            
            var upTileNum:int;
            var leftTileNum:int;
            
            for(var i:int=0; i < 10; i++) tileArr[i] = "character_0" + i + ".png";
            for(i=10; i < TILE_TOTAL; i++) tileArr[i] = "character_" + i + ".png";
            for(i=0; i < TILE_TOTAL; i++) tileTextures[i] = assetManager.getTextureAtlas("inGameUI").getTexture(tileArr[i]);
            for(i=0; i < FIELD_HEIGTH; i++)
            {
                stageTileNum[i]       = new Array(FIELD_WIDTH);
                stageTileImage[i]     = new Array(FIELD_WIDTH);
                stageTilePos[i]       = new Array(FIELD_WIDTH);
                stageTileMinusPos[i]  = new Array(FIELD_WIDTH);
                
                for(var j:int=0; j < FIELD_WIDTH; j++)
                {
                    if(i == 0 || j == 0)
                    {
                        if(i == 0) upTileNum   = -1;
                        else       upTileNum   = stageTileNum[i-1][j];
                        if(j == 0) leftTileNum = -1;
                        else       leftTileNum = stageTileNum[i][j-1];
                    }
                    else
                    {
                        upTileNum = stageTileNum[i-1][j];
                        leftTileNum = stageTileNum[i][j-1];
                    }
                    
                    stageTileNum[i][j] = Math.floor((Math.random())*TILE_TYPE);
                    while(stageTileNum[i][j] == upTileNum || stageTileNum[i][j] == leftTileNum) stageTileNum[i][j] = Math.floor((Math.random())*TILE_TYPE);
                    
                    stageTileImage[i][j] = new Image(tileTextures[stageTileNum[i][j]]);
                    stageTilePos[i][j] = new Point(j * stageTileImage[i][j].width, i * stageTileImage[i][j].height);
                    stageTileMinusPos[i][j] = new Point(j * stageTileImage[i][j].width, -(i+1) * stageTileImage[i][j].height);
                    stageTileImage[i][j].x = stageTilePos[i][j].x;
                    stageTileImage[i][j].y = stageTilePos[i][j].y;
                    
                    stageTileImage[i][j].addEventListener(starling.events.TouchEvent.TOUCH, inGameStageTouch);
                    _inGameStage.addChild(stageTileImage[i][j]);
                }
            }
            
            addChild(_inGameStage);
        }
        
        private function stageTileChange():void
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
                    
                    if(stageTileNum[j][i] == -1)
                    {
                        for(var q:int=j; 0 <= q; q--)
                        {
                            if(stageTileNum[q][i] != -1)
                            {
                                stageTileNum[j][i] = stageTileNum[q][i];
                                stageTileImage[j][i].texture = tileTextures[stageTileNum[j][i]];
                                TweenLite.from(stageTileImage[j][i], 0.2*(j-q), {x:stageTilePos[q][i].x, y: stageTilePos[q][i].y});
                                if(maxTweenTime < 0.2*(j-q)) maxTweenTime = 0.2*(j-q);
                                stageTileNum[q][i] = -1;
                                isUpTileExist = true;
                                break;
                            }
                        }
                        if(!isUpTileExist)
                        {
                            stageTileNum[j][i] = Math.floor((Math.random())*TILE_TYPE);
                            stageTileImage[j][i].texture = tileTextures[stageTileNum[j][i]];
                            TweenLite.from(stageTileImage[j][i], 0.2*(minusLineIdx+j+1), {x:stageTileMinusPos[minusLineIdx][i].x, y: stageTileMinusPos[minusLineIdx][i].y});
                            if(maxTweenTime < 0.2*(minusLineIdx+j+1)) maxTweenTime = 0.2*(minusLineIdx+j+1);
                            minusLineIdx++;
                        }
                    }
                }
            }
            
            TweenLite.delayedCall(maxTweenTime, resetTouch);
        }
        
        private function tileCheckHorizon(index:int):Boolean
        {
            var cnt:int = 0;
            var tileNum:int = stageTileNum[index][0];
            var result:Boolean = false;
            
            for(var i:int=0; i < FIELD_WIDTH; i++)
            {
                if(tileNum == stageTileNum[index][i])
                {
                    cnt++;
                    
                    if(i == (FIELD_WIDTH-1) && cnt >= 3)
                    {
                        result = true;
                        
                        while(cnt != 0)
                        {
                            cnt--;
                            stageTileNum[index][i-cnt] = -1;
                        }
                    }
                }
                else
                {
                    if(cnt >= 3)
                    {
                        result = true;
                        
                        while(cnt > 0)
                        {
                            stageTileNum[index][i-cnt] = -1;
                            cnt--;
                        }
                    }
                    else
                    {
                        cnt = 1;
                        tileNum = stageTileNum[index][i];
                    }
                }
            }
            
            return result;
        }
        
        private function tileCheckVertical(index:int):Boolean
        {
            var cnt:int = 0;
            var tileNum:int = stageTileNum[0][index];
            var result:Boolean = false;
            
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                if(tileNum == stageTileNum[i][index])
                {
                    cnt++;
                    
                    if(i == (FIELD_HEIGTH-1) && cnt >= 3)
                    {
                        result = true;
                        
                        while(cnt != 0)
                        {
                            cnt--;
                            stageTileNum[i-cnt][index] = -1;
                        }
                    }
                }
                else
                {
                    if(cnt >= 3)
                    {
                        result = true;
                        
                        while(cnt > 0)
                        {
                            stageTileNum[i-cnt][index] = -1;
                            cnt--;
                        }
                    }
                    else
                    {
                        cnt = 1;
                        tileNum = stageTileNum[i][index];
                    }
                }
            }
            
            return result;
        }
        
        private function tileCheckAll():Boolean
        {
            var cnt:int;
            var tileNum:int;
            var result:Boolean = false;
            
            _inGameStage.touchable = false;
            
            for(var i:int=0; i < FIELD_HEIGTH; i++)
            {
                if(tileCheckHorizon(i)) result = true;
            }
            
            for(i=0; i < FIELD_WIDTH; i++)
            {
                if(tileCheckVertical(i)) result = true;
            }
            
            return result;
        }
        
        private function inGameStageTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(_inGameStage);
            if(touch != null)
            {
                if(touch.phase == TouchPhase.BEGAN)
                {
                    _mouseButtonDown = true;
                    
                    _currentTileX = (touch.globalX - _inGameStage.x) / TILE_LENGTH_SCALED;
                    _currentTileY = (touch.globalY - _inGameStage.y) / TILE_LENGTH_SCALED;
                }
                else if(touch.phase == TouchPhase.ENDED)
                {
                    _mouseButtonDown = false;
                }
                else if(touch.phase == TouchPhase.MOVED && _mouseButtonDown == true)
                {
                    _newTileX = (touch.globalX - _inGameStage.x) / TILE_LENGTH_SCALED;
                    _newTileY = (touch.globalY - _inGameStage.y) / TILE_LENGTH_SCALED;
                    
                    if(_newTileX < 0 || _newTileX >= FIELD_WIDTH || _newTileY < 0 || _newTileY >= FIELD_HEIGTH) _mouseButtonDown = false;
                    else if(_currentTileX != _newTileX || _currentTileY != _newTileY)
                    {
                        _mouseButtonDown = false;
                        _inGameStage.touchable = false;
                        _tileChecking = true;
                        
                        touchTileChange(_currentTileX, _currentTileY, _newTileX, _newTileY);
                    }
                }
            }
        }
        
        private function touchTileChange(idx1:int, idx2:int, idx3:int, idx4:int):void
        {
            var temp:int = stageTileNum[idx2][idx1];
            stageTileNum[idx2][idx1] = stageTileNum[idx4][idx3];
            stageTileNum[idx4][idx3] = temp;
            
            stageTileImage[idx2][idx1].texture = tileTextures[stageTileNum[idx2][idx1]];
            stageTileImage[idx4][idx3].texture = tileTextures[stageTileNum[idx4][idx3]];
            
            TweenLite.from(stageTileImage[idx2][idx1], 0.2, {x:stageTilePos[idx4][idx3].x, y: stageTilePos[idx4][idx3].y});
            TweenLite.from(stageTileImage[idx4][idx3], 0.2, {x:stageTilePos[idx2][idx1].x, y: stageTilePos[idx2][idx1].y, onComplete:touchTileChangeComplete});
        }
        
        private function touchTileChangeComplete():void
        {
            if(_tileChecking)
            {
                _tileChecking = false;
                
                if(!touchTileCheck(_currentTileY, _currentTileX, _newTileY, _newTileX))
                {
                    touchTileChange(_currentTileX, _currentTileY, _newTileX, _newTileY);
                }
            }
            else _inGameStage.touchable = true;
        }
        
        private function touchTileCheck(idx1:int, idx2:int, idx3:int, idx4:int):Boolean
        {
            var result:Boolean = false;
            
            if(tileCheckHorizon(idx1)) result = true;
            if(tileCheckVertical(idx2)) result = true;
            if(tileCheckHorizon(idx3)) result = true;
            if(tileCheckVertical(idx4)) result = true;
            
            if(result) stageTileChange();
            
            return result;
        }
        
        private function resetTouch():void
        {
            if(tileCheckAll())
            {
                stageTileChange();
            }
            else _inGameStage.touchable = true;
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
            tileTextures.length = 0;
            tileTextures = null;
            stageTileNum.length = 0;
            stageTileNum = null;
            stageTileImage.length = 0;
            stageTileImage = null;
            stageTilePos.length = 0;
            stageTilePos = null;
            stageTileMinusPos.length = 0;
            stageTileMinusPos = null;
            _inGameStage.removeEventListeners();
            while(_inGameStage.numChildren > 0) _inGameStage.removeChildAt(0);
            this.removeChild(_inGameStage);
            _inGameStage.dispose();
            _inGameUI.dispose();
            _inGameUI = null;
            this.removeEventListeners();
            while(this.numChildren > 0) this.removeChildAt(0);
            this.parent.removeChild(this);
            this.dispose();
        }
    }
}