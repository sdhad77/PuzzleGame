package N2P2.utils
{
    import com.greensock.TweenLite;
    
    import starling.display.Image;
    
    /**
     * 게임 보드 위에 존재하는 타일의 클래스입니다.
     * @author 신동환
     */
    public class Tile extends Image
    {
        private var _num:int;  //텍스쳐 넘버
        private var _type:int; //타일의 타입. 일반,가로,세로,크로스,유령
        private var _char:int; //타일의 캐릭터. 팡이, 핑키, 등등..
        
        public function Tile(num:int)
        {
            _num = num;
            _type = num/GlobalData.TILE_CHAR;
            _char = num%GlobalData.TILE_CHAR;
            super(GlobalData.TILE_TEXTURE[num]);
        }
        
        /**
         * 타일을 변경하는 함수.
         * @param num num 타일로 변경
         */
        public function change(num:int):void
        {
            _num = num;
            _type = num/GlobalData.TILE_CHAR;
            _char = num%GlobalData.TILE_CHAR;
            this.texture = GlobalData.TILE_TEXTURE[num];
        }
        
        /**
         * 타일을 변경하는 함수. visible을 true로 자동 변경해줌
         * @param num num 타일로 변경
         */
        public function mark(num:int):void
        {
            change(num);
            this.visible = true;
        }
        
        /**
         * 타일의 타입만 변경하는 함수
         * @param type type으로 타일의 타입 변경
         */
        public function changeType(type:int):void
        {
            _type = type;
            if(_type < GlobalData.TILE_TYPE_GHOST) _num = type * GlobalData.TILE_CHAR;
        }
        
        /**
         * 두개의 타일을 교체
         * @param tile 교체할 타일
         * @param func 콜백함수
         */
        public function swap(tile:Tile, func:Function = null):void
        {
            var temp1:int = this.num;
            var temp2:int = tile.num;
            var posX:Number = this.x;
            var posY:Number = this.y;
            
            this.change(temp2);
            tile.change(temp1);
            
            TweenLite.from(this, GlobalData.TWEEN_TIME, {x:tile.x, y: tile.y});
            TweenLite.from(tile, GlobalData.TWEEN_TIME, {x:posX, y: posY, onComplete: func});
        }
        
        /**
         * 특정위치 -> 현재위치로의 애니메이션 함수
         * @param addX 특정위치X
         * @param addY 특정위치Y
         */
        public function moveFrom(addX:String = null, addY:String = null):void
        {
            TweenLite.from(this, GlobalData.TWEEN_TIME, {x: addX, y: addY});
        }
        
        /**
         * 현재위치 -> 특정위치로의 애니메이션 함수
         * @param posX 특정위치X
         * @param posY 특정위치Y
         */
        public function moveTo(posX:int, posY:int):void
        {
            TweenLite.to(this, GlobalData.TWEEN_TIME, {x: posX, y: posY});
        }
        
        /**
         * 타일을 보드에서 안보이게 해주는 함수
         * @return 타입이 0보다 클 경우 true반환. 특수 타일임을 의미함
         */
        public function vanishFromBoard():Boolean
        {
            if(this.visible == true)
            {
                this.visible = false;
                if(_type > 0) return true;
            }
            
            return false;
        }
        
        public function visibleOn():void
        {
            this.visible = true;
        }
        
        public function visibleOff():void
        {
            this.visible = false;
        }
        
        public function get num():int  { return _num;  }
        public function get type():int { return _type; }
        public function get char():int { return _char; }
        
        public function set num(value:int):void  { _num = value;  }
        public function set type(value:int):void { _type = value; }
        public function set char(value:int):void { _char = value; }
    }
}