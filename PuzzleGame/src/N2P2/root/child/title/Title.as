package N2P2.root.child.title
{
    import N2P2.root.Game;
    import N2P2.utils.GlobalData;
    import N2P2.utils.UserInterface;
    
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class Title extends Sprite
    {
        private var _ui:UserInterface;
        
        public function Title()
        {
            super();
        }
        
        public function start():void
        {
            drawTitle();
        }
        
        private function drawTitle():void
        {
            _ui = new UserInterface(GlobalData.ASSET_MANAGER.getTextureAtlas("titleUI"), "title_");
            addChild(_ui);
            
            _ui.addTouchEventByName("title_1.png", startButtonClick);
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void
        {
            var currentDate:Date = new Date();
            _ui.getChildByName("title_1.png").y = this.height*0.8 + Math.cos(currentDate.getTime() * 0.004) * 5;
        }
        
        private function startButtonClick(event:TouchEvent):void
        {
            if(event.getTouch(this, TouchPhase.BEGAN))
            {
                (this.root as Game).startWorldMap();
                clear();
            }
        }
        
        private function clear():void
        {
            _ui.dispose();
            _ui = null;
            this.removeEventListeners();
            this.parent.removeChild(this);
            this.dispose();
        }
    }
}