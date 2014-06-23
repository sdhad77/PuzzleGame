package N2P2.utils
{
    import com.greensock.TweenLite;
    
    import starling.events.TouchEvent;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.display.DisplayObjectContainer;
    import starling.display.Image;
    
    /**
     * 자동으로 UI를 생성해주는 클래스입니다.</br>
     * flash CC -> swf -> png의 과정을 거친 아틀라스이미지를 사용하면 됩니다.
     * @author 신동환
     */
    public class UserInterface extends DisplayObjectContainer
    {
        public function UserInterface(textureAtlas:TextureAtlas, name:String)
        {
            init(textureAtlas, name);
        }
        
        /**
         * 초기화 하는 함수
         * @param textureAtlas 이 UI에서 사용할 아틀라스 이미지
         * @param name this에서 사용할 UI의 이름
         */
        private function init(textureAtlas:TextureAtlas, name:String):void
        {
            this.name = name;
            
            var mTextures:Vector.<Texture> = textureAtlas.getTextures(name);
            var mNames:Vector.<String> = textureAtlas.getNames(name);
            var tempFrameX:Number;
            var tempFrameY:Number;
            
            for(var i:int=0; i< mTextures.length; i++)
            {
                this.addChild(new Image(mTextures[i]));
                this.getChildAt(i).x = -mTextures[i].frame.x;
                this.getChildAt(i).y = -mTextures[i].frame.y;
                this.getChildAt(i).name = mNames[i];
            }
            
            //메모리 해제
            mTextures.length = 0;
            mTextures = null;
            
            mNames.length = 0;
            mNames = null;
        }
        
        /**
         * UI의 등장 애니메이션 효과. 팝업창에서 사용하면 됩니다.
         * @param func callBack 함수
         */
        public function appearanceAnimation(func:Function = null):void
        {
            visible = true;
            
            TweenLite.from(this, 0.2, {x: stage.stageWidth/2-this.width/10, y:stage.stageHeight/2-this.height/10, scaleX:0.1 , scaleY:0.1, onComplete:completeFunc});
            
            function completeFunc():void
            {
                touchable = true;
                if(func != null) func();
            }
        }
        
        /**
         * UI의 사라지는 애니메이션 효과. 팝업창에서 사용하면 됩니다.
         * @param func callBack 함수
         */
        public function disappearanceAnimation(func:Function = null):void
        {
            touchable = false;
            
            TweenLite.to(this, 0.2, {x: stage.stageWidth/2-this.width/10, y:stage.stageHeight/2-this.height/10, scaleX:0.1 , scaleY:0.1, onComplete:completeFunc});
            
            function completeFunc():void
            {
                visible = false;
                x = 0;
                y = 0;
                scaleX *= 10;
                scaleY *= 10;
                if(func != null) func();
            }
        }
        
        /**
         * 특정 이미지에 touch 이벤트 추가
         * @param index this의 child 인덱스
         * @param func 콜백함수
         */
        public function addTouchEventAt(index:int, func:Function):void
        {
            this.getChildAt(index).addEventListener(TouchEvent.TOUCH, func);
        }
        
        /**
         * 특정 이미지에 touch 이벤트 추가
         * @param name this의 child 이름
         * @param func 콜백함수
         */
        public function addTouchEventByName(name:String, func:Function):void
        {
            this.getChildByName(name).addEventListener(TouchEvent.TOUCH, func);
        }
        
        /**
         * 특정 이미지의 touch 이벤트 제거
         * @param index this의 child 인덱스
         * @param func 콜백함수
         */
        public function removeTouchEventAt(index:int, func:Function):void
        {
            this.getChildAt(index).removeEventListener(TouchEvent.TOUCH, func);
        }
        
        /**
         * 특정 이미지의 touch 이벤트 제거
         * @param index this의 child 이름
         * @param func 콜백함수
         */
        public function removeTouchEventByName(name:String, func:Function):void
        {
            this.getChildByName(name).removeEventListener(TouchEvent.TOUCH, func);
        }
        
        /**
         * this에서 특정 child를 이름으로 찾아, 제거
         * @param name 제거할 child의 이름
         */
        public function removeChildByName(name:String):void
        {
            this.removeChild(this.getChildByName(name));
        }
        
        /**
         * this의 모든 child를 제거하는 함수
         */
        public function removeAllChild():void
        {
            while(this.numChildren > 0)
            {
                this.getChildAt(0).removeEventListeners();
                this.removeChildAt(0);
            }
        }
        
        /**
         * this의 child, 이벤트리스너를 제거하고, this의 부모에서 this를 제거
         */
        override public function dispose():void
        {
            removeAllChild();
            this.removeEventListeners();
            if(this.parent != null && this.parent != this) this.parent.removeChild(this);
        }
    }
}