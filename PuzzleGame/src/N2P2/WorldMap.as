package N2P2
{
    import starling.display.Sprite;
    import starling.display.UserInterface;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;

    public class WorldMap extends Sprite
    {
        private var _ui:UserInterface;
        private var _mouseButtonDown:Boolean;
        private var _rightSide:Number;
        
        public function WorldMap()
        {
            super();
        }
        
        public function start(assetManager:AssetManager):void
        {
            _mouseButtonDown = false;
            
            drawWorldMap(assetManager);
        }
        
        private function drawWorldMap(assetManager:AssetManager):void
        {
            _ui = new UserInterface(assetManager.getTextureAtlas("ui"), "worldMap");
            addChild(_ui);
            
            _rightSide = _ui.getChildByName("worldMap_1.png").height + _ui.getChildByName("worldMap_2.png").width;
            
            _ui.addTouchEventByName("worldMap_0.png", mapClick);
            _ui.addTouchEventByName("worldMap_1.png", mapClick);
            _ui.addTouchEventByName("worldMap_2.png", mapClick);
            
            _ui.addTouchEventByName("worldMap_3.png", stageButtonClick);
            _ui.addTouchEventByName("worldMap_4.png", stageButtonClick);
            _ui.addTouchEventByName("worldMap_5.png", stageButtonClick);
            _ui.addTouchEventByName("worldMap_6.png", stageButtonClick);
        }
        
        private function mapClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if(touch != null)
            {
                if(touch.phase == TouchPhase.BEGAN)
                {
                    _mouseButtonDown = true
                }
                else if(touch.phase == TouchPhase.ENDED)
                {
                    _mouseButtonDown = false;
                }
                else if(touch.phase == TouchPhase.MOVED && _mouseButtonDown == true)
                {
                    var temp:Number = this.root.x + touch.globalX - touch.previousGlobalX;
                    if(temp > 0) this.root.x = 0;
                    else if(temp < -_rightSide) this.root.x = -_rightSide;
                    else this.root.x += touch.globalX - touch.previousGlobalX;
                }
            }
        }
        
        private function stageButtonClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) trace("clicked");
        }
    }
}