package N2P2
{
    import starling.display.Sprite;
    import starling.display.UserInterface;
    import starling.events.Event;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;

    public class Title extends Sprite
    {
        private var _ui:UserInterface;
        
        public function Title()
        {
            super();
        }
        
        public function start(assetManager:AssetManager):void
        {
            drawTitle(assetManager);
        }
        
        private function drawTitle(assetManager:AssetManager):void
        {
            _ui = new UserInterface(assetManager.getTextureAtlas("ui"), "title");
            addChild(_ui);
            
            _ui.addTouchEventByName("title_3.png", noticeCloseButtonClick);
            _ui.addTouchEventByName("title_4.png", startButtonClick);
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void
        {
            var currentDate:Date = new Date();
            _ui.getChildByName("title_4.png").y = 900 + Math.cos(currentDate.getTime() * 0.002) * 5;
        }
        
        private function noticeCloseButtonClick(event:TouchEvent):void
        {
            if(event.getTouch(_ui, TouchPhase.BEGAN))
            {
                _ui.removeTouchEventByName("title_3.png", noticeCloseButtonClick);
                _ui.removeChildByName("title_1.png");
                _ui.removeChildByName("title_2.png");
                _ui.removeChildByName("title_3.png");
            }
        }
        
        private function startButtonClick(event:TouchEvent):void
        {
            if(event.getTouch(_ui, TouchPhase.BEGAN))
            {
                _ui.removeTouchEventByName("title_4.png", startButtonClick);
                _ui.dispose();
                _ui = null;
                this.parent.removeChild(this);
                this.dispose();
            }
        }
    }
}