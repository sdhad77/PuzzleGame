package N2P2
{
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.display.UserInterface;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;

    public class WorldMap extends Sprite
    {
        private var _ui:UserInterface;
        private var _sbp:UserInterface; //stage Button Popup
        private var _mouseButtonDown:Boolean;
        private var _rightSide:Number;
        private var _selectStageNum:int;
        
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
            _ui = new UserInterface(assetManager.getTextureAtlas("ui"), "worldMap_");
            addChild(_ui);
            
            _sbp = new UserInterface(assetManager.getTextureAtlas("ui"), "worldMapSBP_");
            addChild(_sbp);
            this.getChildByName("worldMapSBP_").visible = false;
            this.getChildByName("worldMapSBP_").touchable = false;
            
            _rightSide = _ui.getChildByName("worldMap_01.png").width + _ui.getChildByName("worldMap_02.png").width;
            
            _ui.addTouchEventByName("worldMap_0.png", mapClick);
            _ui.addTouchEventByName("worldMap_01.png", mapClick);
            _ui.addTouchEventByName("worldMap_02.png", mapClick);
            
            _sbp.addTouchEventByName("worldMapSBP_1.png", gameStart);
            _sbp.addTouchEventByName("worldMapSBP_2.png", gameStartCancle);
            
            for(var i:int=3; i<10; i++) _ui.addTouchEventByName("worldMap_0" + i + ".png", stageButtonClick);
            for(i=10; i<18; i++) _ui.addTouchEventByName("worldMap_" + i + ".png", stageButtonClick);
        }
        
        private function gameStartCancle(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                _sbp.touchable = false;
                _sbp.visible = false;
                _ui.touchable = true;
            }
        }
        
        private function gameStart(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                this.root.x = 0;
                (this.root as Game).startInGame(_selectStageNum);
                clear();
            }
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
            if(touch != null) 
            {
                var name:String = (event.target as DisplayObject).name;
                _selectStageNum = Number(name.substring(name.indexOf("_")+1,name.indexOf("."))) - 2;
                
                _ui.touchable = false;
                _sbp.touchable = true;
                _sbp.x = -this.root.x;
                _sbp.visible = true;
            }
        }
        
        private function clear():void
        {
            _ui.dispose();
            _ui = null;
            _sbp.dispose();
            _sbp = null;
            this.removeEventListeners();
            this.parent.removeChild(this);
            this.dispose();
        }
    }
}