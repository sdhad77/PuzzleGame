package N2P2.root.child 
{
    import com.greensock.TweenLite;
    
    import N2P2.root.Game;
    import N2P2.utils.UserInterface;
    
    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;

    public class InGame extends Sprite
    {
        private var _inGameBoard:InGameBoard;
        private var _inGameUI:UserInterface;
        private var _pausePopupUI:UserInterface;
        private var _missionFailUI:UserInterface;
        private var _missionCompleteUI:UserInterface;
        private var _inGameClearUI:UserInterface;
        private var _resetTileUI:UserInterface;
        
        public function InGame()
        {
            super();
        }
        
        public function start(assetManager:AssetManager, stageNum:Number):void
        {
            init(assetManager, stageNum);
        }
        
        private function init(assetManager:AssetManager, stageNum:Number):void
        {
            _inGameUI = new UserInterface(assetManager.getTextureAtlas("inGameUI"), "inGameUI_");
            _inGameUI.addTouchEventByName("inGameUI_2.png", pausePopupButtonTouch);
            addChild(_inGameUI);
            
            _inGameBoard = new InGameBoard(stageNum, assetManager);
            _inGameBoard.scaleX = _inGameBoard.scaleY = 0.4;
            _inGameBoard.x = (Starling.current.viewPort.width >> 1) - ((8 * 64) >> 1);
            _inGameBoard.y = (Starling.current.viewPort.height >> 1) - ((8 * 64) >> 1);
            addChild(_inGameBoard);
            
            _pausePopupUI = new UserInterface(assetManager.getTextureAtlas("inGameUI"), "inGameUIPausePopup_");
            _pausePopupUI.touchable = false;
            _pausePopupUI.visible = false;
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_1.png", pausePopupClose);//popupclose
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_2.png", pausePopupClose);//continue
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_3.png", restartGameButtonTouch);//restartclose
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_4.png", returnWorldMapButtonTouch);//returnclose
            addChild(_pausePopupUI);
            
            _missionFailUI = new UserInterface(assetManager.getTextureAtlas("inGameUI"), "inGameFail_");
            _missionFailUI.visible = false;
            addChild(_missionFailUI);
            
            _missionCompleteUI = new UserInterface(assetManager.getTextureAtlas("inGameUI"), "inGameClear_");
            _missionCompleteUI.visible = false;
            addChild(_missionCompleteUI);
            
            _inGameClearUI = new UserInterface(assetManager.getTextureAtlas("inGameUI"), "inGameClear2_");
            _inGameClearUI.visible = false;
            addChild(_inGameClearUI);
            
            _resetTileUI = new UserInterface(assetManager.getTextureAtlas("inGameUI"), "inGameTileReset_");
            _resetTileUI.visible = false;
            addChild(_resetTileUI);
        }
        
        private function pausePopupButtonTouch(event:TouchEvent):void
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
        
        private function restartGameButtonTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) this.removeChild(_inGameBoard);
        }
        
        private function returnWorldMapButtonTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) returnWorldMap();
        }
        
        private function returnWorldMap():void
        {
            (this.root as Game).startWorldMap();
            clear();
        }
        
        public function resetTile():void
        {
            _inGameBoard.touchable = false;
            _inGameUI.touchable = false;
            _resetTileUI.appearanceAnimation();
        }
        
        public function resetTileComplete():void
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