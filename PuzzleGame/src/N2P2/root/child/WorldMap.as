package N2P2.root.child
{
    import N2P2.root.Game;
    import N2P2.utils.UserInterface;
    
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.AssetManager;

    public class WorldMap extends Sprite
    {
        private var _worldMap:UserInterface;
        private var _ssp:UserInterface;        //stage Select Popup
        private var _sspContents:UserInterface;// stage Select Popup 위에 사용할 ui. stage별로 다른 UI사용
        private var _isp:UserInterface;        //item Select Popup
        private var _mb:UserInterface;         //menu Button
        private var _mp:UserInterface;         //menu Popup
        
        private var _mouseButtonDown:Boolean;
        private var _rightSide:Number;
        private var _selectStageNum:int;
        
        private var _assetManager:AssetManager;
        
        public function WorldMap()
        {
            super();
        }
        
        public function start(assetManager:AssetManager):void
        {
            _mouseButtonDown = false;
            _assetManager = assetManager;
            
            drawWorldMap(assetManager);
        }
        
        private function drawWorldMap(assetManager:AssetManager):void
        {
            _worldMap = new UserInterface(assetManager.getTextureAtlas("worldMap"), "worldMap_");
            addChild(_worldMap);
            
            _mb = new UserInterface(assetManager.getTextureAtlas("worldMapUI"), "worldMapMB_");
            addChild(_mb);
            
            _ssp = new UserInterface(assetManager.getTextureAtlas("worldMapUI"), "stageSelectPopup_");
            _ssp.visible = false;
            _ssp.touchable = false;
            addChild(_ssp);
            
            _isp = new UserInterface(assetManager.getTextureAtlas("worldMapUI"), "itemSelectPopup_");
            _isp.visible = false;
            _isp.touchable = false;
            addChild(_isp);
            
            _mp = new UserInterface(assetManager.getTextureAtlas("worldMapUI"), "worldMapMP_");
            _mp.visible = false;
            _mp.touchable = false;
            addChild(_mp);
            
            //================================================================================
            
            _worldMap.addTouchEventByName("worldMap_00.png", mapClick);
            _worldMap.addTouchEventByName("worldMap_01.png", mapClick);
            _worldMap.addTouchEventByName("worldMap_02.png", mapClick);
            
            for(var i:int=3; i<10; i++) _worldMap.addTouchEventByName("worldMap_0" + i + ".png", stageSelectClick);
            for(i=10; i<18; i++)        _worldMap.addTouchEventByName("worldMap_" + i + ".png", stageSelectClick);
            
            _mb.addTouchEventByName("worldMapMB_0.png", heartClick);
            _mb.addTouchEventByName("worldMapMB_1.png", heartClick);
            _mb.addTouchEventByName("worldMapMB_2.png", heartClick);
            _mb.addTouchEventByName("worldMapMB_3.png", heartClick);
            _mb.addTouchEventByName("worldMapMB_4.png", heartClick);
            
            _ssp.addTouchEventByName("stageSelectPopup_04.png", stageSelectPopupClose);
            _ssp.addTouchEventByName("stageSelectPopup_05.png", itemSelectPopupClick);
            _ssp.getChildByName("stageSelectPopup_06.png").visible = false; //애니
            _ssp.getChildByName("stageSelectPopup_07.png").visible = false; //별한개
            _ssp.getChildByName("stageSelectPopup_08.png").visible = false; //별두개
            _ssp.getChildByName("stageSelectPopup_09.png").visible = false; //별세개
            
            _isp.addTouchEventByName("itemSelectPopup_04.png", itemSelectPopupClose);
            _isp.addTouchEventByName("itemSelectPopup_06.png", itemSelectButtonClick); //item1
            _isp.addTouchEventByName("itemSelectPopup_07.png", itemSelectButtonClick); //item2
            _isp.addTouchEventByName("itemSelectPopup_08.png", itemSelectButtonClick); //item3
            _isp.addTouchEventByName("itemSelectPopup_09.png", gameStart);
            
            _mp.addTouchEventByName("worldMapMP_1.png", menuPopupCloseClick);
            
            //================================================================================
            
            _rightSide = _worldMap.getChildByName("worldMap_01.png").width + _worldMap.getChildByName("worldMap_02.png").width -1;
        }
        
        private function stageSelectClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                var name:String = (event.target as DisplayObject).name;
                _selectStageNum = Number(name.substring(name.indexOf("_")+1,name.indexOf("."))) - 2;
                
                _worldMap.touchable = false;
                _mb.touchable = false;
                _sspContents = new UserInterface(_assetManager.getTextureAtlas("worldMapUI"), "stage" + _selectStageNum.toString() + "_");
                _sspContents.name = "contents";
                _ssp.addChild(_sspContents);
                _ssp.appearanceAnimation();
            }
        }
        
        private function stageSelectPopupClose(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                _ssp.disappearanceAnimation(sspContentsRemove);
                _worldMap.touchable = true;
                _mb.touchable = true;
            }
        }
        
        private function itemSelectPopupClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                _ssp.visible = false;
                _ssp.touchable = false;
                _isp.appearanceAnimation(sspContentsRemove);
            }
        }
        
        private function itemSelectButtonClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                trace("item 선택");
            }
        }
        
        private function itemSelectPopupClose(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                _isp.disappearanceAnimation();
                _worldMap.touchable = true;
                _mb.touchable = true;
            }
        }
        
        private function gameStart(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                (this.root as Game).startInGame(_selectStageNum);
                clear();
            }
        }
        
        private function heartClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                _mp.appearanceAnimation();
                _worldMap.touchable = false;
                _mb.touchable = false;
            }
        }
        
        private function menuPopupCloseClick(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch != null) 
            {
                _mp.disappearanceAnimation();
                _worldMap.touchable = true;
                _mb.touchable = true;
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
                    var temp:Number = _worldMap.x + touch.globalX - touch.previousGlobalX;
                    if(temp > 0) _worldMap.x = 0;
                    else if(temp < -_rightSide) _worldMap.x = -_rightSide;
                    else _worldMap.x += touch.globalX - touch.previousGlobalX;
                }
            }
        }
        
        private function sspContentsRemove():void
        {
            _ssp.removeChildByName("contents");
            _sspContents.dispose();
            _sspContents = null;
        }
        
        private function clear():void
        {
            _assetManager = null;
            
            if(_worldMap != null)
            {
                _worldMap.dispose();
                _worldMap = null;
            }
            if(_sspContents != null)
            {
                _sspContents.dispose();
                _sspContents = null;
            }
            if(_ssp != null)
            {
                _ssp.dispose();
                _ssp = null;
            }
            if(_isp != null)
            {
                _isp.dispose();
                _isp = null;
            }
            if(_mp != null)
            {
                _mp.dispose();
                _mp = null;
            }
            if(_mb != null)
            {
                _mb.dispose();
                _mb = null;
            }
            
            this.removeEventListeners();
            this.parent.removeChild(this);
            this.dispose();
        }
    }
}