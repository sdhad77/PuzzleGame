package N2P2.root.child.ingame 
{
    import com.greensock.TweenLite;
    
    import N2P2.root.Game;
    import N2P2.root.child.ingame.utils.Board;
    import N2P2.utils.GlobalData;
    import N2P2.utils.UserInterface;
    
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.text.TextField;

    public class InGame extends Sprite
    {
        private var _inGameBoard:Board;
        private var _inGameUI:UserInterface;
        private var _pausePopupUI:UserInterface;
        private var _missionFailUI:UserInterface;
        private var _missionCompleteUI:UserInterface;
        private var _inGameClearUI:UserInterface;
        private var _resetTileUI:UserInterface;
        
        private var _tfMoveNum:TextField;
        private var _tfMoveNumPosX:Number;
        private var _tfMoveNumPosY:Number;
        
        private var _tfPoint:TextField;
        private var _tfPointPosX:Number;
        private var _tfPointPosY:Number;
        
        private var _tfStageName:TextField;
        private var _tfStageNamePosX:Number;
        private var _tfStageNamePosY:Number;
        
        private var _stageNum:Number;
        
        public function InGame()
        {
            super();
        }
        
        public function start(stageNum:Number):void
        {
            init(stageNum);
        }
        
        private function init(stageNum:Number):void
        {
            _stageNum = stageNum;
            
            _inGameUI = new UserInterface(GlobalData.ASSET_MANAGER.getTextureAtlas("inGameUI"), "inGameUI_");
            _inGameUI.addTouchEventByName("inGameUI_2.png", pausePopupButtonClick);
            addChild(_inGameUI);
            
            _inGameBoard = new Board(stageNum);
            _inGameBoard.scaleX = _inGameBoard.scaleY = GlobalData.INGAME_STAGE_SCALE;
            _inGameBoard.x = (this.width >> 1) - ((GlobalData.FIELD_WIDTH * GlobalData.TILE_LENGTH_SCALED) >> 1);
            _inGameBoard.y = (this.height >> 1) - ((GlobalData.FIELD_HEIGTH * GlobalData.TILE_LENGTH_SCALED) >> 1);
            addChild(_inGameBoard);
            
            _pausePopupUI = new UserInterface(GlobalData.ASSET_MANAGER.getTextureAtlas("inGameUI"), "inGameUIPausePopup_");
            _pausePopupUI.touchable = false;
            _pausePopupUI.visible = false;
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_1.png", pausePopupClose);//popupclose
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_2.png", pausePopupClose);//continue
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_3.png", restartGameButtonClick);//restartclose
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_4.png", returnWorldMapButtonClick);//returnclose
            addChild(_pausePopupUI);
            
            _missionFailUI = new UserInterface(GlobalData.ASSET_MANAGER.getTextureAtlas("inGameUI"), "inGameFail_");
            _missionFailUI.visible = false;
            addChild(_missionFailUI);
            
            _missionCompleteUI = new UserInterface(GlobalData.ASSET_MANAGER.getTextureAtlas("inGameUI"), "inGameClear_");
            _missionCompleteUI.visible = false;
            addChild(_missionCompleteUI);
            
            _inGameClearUI = new UserInterface(GlobalData.ASSET_MANAGER.getTextureAtlas("inGameUI"), "inGameClear2_");
            _inGameClearUI.visible = false;
            addChild(_inGameClearUI);
            
            _resetTileUI = new UserInterface(GlobalData.ASSET_MANAGER.getTextureAtlas("inGameUI"), "inGameTileReset_");
            _resetTileUI.visible = false;
            addChild(_resetTileUI);
            
            _tfMoveNumPosX = GlobalData.TEXTFIELD_MOVENUM_POS_X * this.width;
            _tfMoveNumPosY = GlobalData.TEXTFIELD_MOVENUM_POS_Y * this.height;
            _tfMoveNum = new TextField(100, 40, "0", "Verdana", GlobalData.TEXTFIELD_MOVENUM_SIZE*this.width, 0xffffff, true);
            _tfMoveNum.width = _tfMoveNum.textBounds.width + 100;
            _tfMoveNum.height = _tfMoveNum.textBounds.height + 10;
            _tfMoveNum.x = _tfMoveNumPosX - _tfMoveNum.width/2;
            _tfMoveNum.y = _tfMoveNumPosY - _tfMoveNum.height/2;
            addChild(_tfMoveNum);
            
            _tfPointPosX = GlobalData.TEXTFIELD_POINT_POS_X * this.width;
            _tfPointPosY = GlobalData.TEXTFIELD_POINT_POS_Y * this.height;
            _tfPoint = new TextField(100, 40, "0", "Verdana", GlobalData.TEXTFIELD_POINT_SIZE*this.width, 0x0, true);
            _tfPoint.width = _tfPoint.textBounds.width + 100;
            _tfPoint.height = _tfPoint.textBounds.height + 10;
            _tfPoint.x = _tfPointPosX;
            _tfPoint.y = _tfPointPosY - _tfPoint.height/2;
            addChild(_tfPoint);
            
            _tfStageNamePosX = GlobalData.TEXTFIELD_STAGENAME_POS_X * this.width;
            _tfStageNamePosY = GlobalData.TEXTFIELD_STAGENAME_POS_Y * this.height;
            _tfStageName = new TextField(100, 40, "STAGE " + stageNum.toString(), "Verdana", GlobalData.TEXTFIELD_STAGENAME_SIZE*this.width, 0x0, true);
            _tfStageName.width = _tfStageName.textBounds.width + 100;
            _tfStageName.height = _tfStageName.textBounds.height + 10;
            _tfStageName.x = _tfStageNamePosX;
            _tfStageName.y = _tfStageNamePosY - _tfStageName.height/2;
            addChild(_tfStageName);
        }
        
        private function pausePopupButtonClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null)
            {
                _pausePopupUI.appearanceAnimation();
                _inGameUI.touchable = false;
                _inGameBoard.touchable = false;
            }
        }
        
        private function pausePopupClose(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null)
            {
                _pausePopupUI.disappearanceAnimation();
                _inGameUI.touchable = true;
                _inGameBoard.touchable = true;
            }
        }
        
        private function restartGameButtonClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null)
            {
                _inGameBoard.removeChildren();
                _inGameBoard.init(_stageNum);
                
                _pausePopupUI.disappearanceAnimation();
                _inGameUI.touchable = true;
                _inGameBoard.touchable = true;
            }
        }
        
        private function returnWorldMapButtonClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) returnWorldMap();
        }
        
        private function returnWorldMap():void
        {
            (this.root as Game).startWorldMap();
            clear();
        }
        
        public function updateMoveNum(moveNum:int):void
        {
            _tfMoveNum.text = moveNum.toString();
            _tfMoveNum.width = _tfMoveNum.textBounds.width + 100;
            _tfMoveNum.x = _tfMoveNumPosX - _tfMoveNum.width/2;
        }
        
        public function updatePoint(point:int):void
        {
            _tfPoint.text = point.toString();
            _tfPoint.width = _tfPoint.textBounds.width + 100;
        }
        
        public function resetTile():void
        {
            _inGameBoard.touchable = false;
            _inGameUI.touchable = false;
            _resetTileUI.appearanceAnimation();
            TweenLite.delayedCall(2, resetTileComplete);
        }
        
        private function resetTileComplete():void
        {
            _inGameBoard.touchable = true;
            _inGameUI.touchable = true;
            _resetTileUI.disappearanceAnimation();
        }
        
        public function missionFail():void
        {
            _inGameBoard.touchable = false;
            _inGameUI.touchable = false;
            _missionFailUI.appearanceAnimation();
            TweenLite.delayedCall(3, inGameFail);
        }
        
        private function inGameFail():void
        {
            _missionFailUI.visible = false;
            returnWorldMap();
        }
        
        public function missionComplete():void
        {
            _inGameBoard.touchable = false;
            _inGameUI.touchable = false;
            _missionCompleteUI.visible = true;
            GlobalData.user.setPoint(_stageNum, Number(_tfPoint.text));
            TweenLite.from(_missionCompleteUI, 0.5, {x: stage.stageWidth/2 - this.width*5/2, y: stage.stageHeight/2 - this.height, scaleX: 5, scaleY: 2});
            TweenLite.delayedCall(2, inGameClear);
        }
        
        private function inGameClear():void
        {
            _missionCompleteUI.visible = false;
            _inGameClearUI.appearanceAnimation();
            TweenLite.delayedCall(1.5, _inGameClearUI.disappearanceAnimation, new Array(returnWorldMap));
        }
        
        private function clear():void
        {
            _inGameBoard.removeEventListeners();
            while(_inGameBoard.numChildren > 0) _inGameBoard.removeChildAt(0);
            this.removeChild(_inGameBoard);
            _inGameBoard.dispose();
            _inGameBoard = null;
            _inGameUI.dispose();
            _inGameUI = null;
            this.removeEventListeners();
            while(this.numChildren > 0) this.removeChildAt(0);
            this.parent.removeChild(this);
            this.dispose();
        }
    }
}