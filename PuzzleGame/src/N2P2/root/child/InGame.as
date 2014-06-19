package N2P2.root.child 
{
    import starling.core.Starling;
    import starling.display.Sprite;
    import N2P2.utils.UserInterface;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;
    import N2P2.root.Game;

    public class InGame extends Sprite
    {
        private var _inGameBoard:InGameBoard;
        private var _inGameUI:UserInterface;
        private var _pausePopupUI:UserInterface;
        
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
            _inGameUI.addTouchEventByName("inGameUI_2.png", pausePopupButtonTouch);
            addChild(_inGameUI);
            
            _inGameBoard = new InGameBoard(assetManager.getTextureAtlas("inGameUI"));
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
            _pausePopupUI.addTouchEventByName("inGameUIPausePopup_4.png", returnWorldMap);//returnclose
            addChild(_pausePopupUI);
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
            if(touch != null)
            {
                this.removeChild(_inGameBoard);
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