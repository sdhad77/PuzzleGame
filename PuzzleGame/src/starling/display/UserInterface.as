package starling.display
{
    import starling.events.TouchEvent;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    
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