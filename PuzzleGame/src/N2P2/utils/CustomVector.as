package N2P2.utils
{
    import flash.geom.Point;

    /**
     * 개인 용도로 제작한 벡터클래스입니다.(Vector.<>이거 아님)
     * @author 신동환
     */
    public class CustomVector
    {
        private var _x:int;                 //벡터의 시작위치X
        private var _y:int;                 //벡터의 시작위치Y
        private var _length:int             //벡터의 길이
        private var _isHorizontal:Boolean;  //이 벡터가 가로인지.
        
        public function CustomVector(x:int, y:int, length:int, isHorizontal:Boolean)
        {
            _x = x;
            _y = y;
            _length = length;
            _isHorizontal = isHorizontal;
        }
        
        /**
         * this와 v1벡터가 교차하는지 검사한다.</br>
         * 교차할 경우 result에 교차점을 집어넣는다.
         * @param v1 비교 벡터
         * @param result 교차점이 저장될 배열
         */
        public function isCross(v1:CustomVector, result:Array):void
        {
            if(v1.x <= this.x && this.x <= (v1.x + v1.length -1) && this.y <= v1.y && v1.y <= (this.y + this.length -1)) result[result.length] = new Point(this.x, v1.y);
        }
        
        /**
         * 특정 좌표가 벡터내에 존재하는지 검사하는 함수이다.
         * @param idx1 x좌표
         * @param idx2 y좌표
         * @return 벡터내에 존재하는지
         */
        public function isExist(idx1:int, idx2:int):Boolean
        {
            if(_isHorizontal == true)
            {
                if(_x == idx1)
                {
                    for(var i:int=0; i<_length; i++)
                    {
                        if((y+i) == idx2) return true;
                    }
                }
                else return false;
            }
            else
            {
                if(_y == idx2)
                {
                    for(i=0; i<_length; i++)
                    {
                        if((x+i) == idx1) return true;
                    }
                }
                else return false;
            }
            
            return false;
        }
        
        public function get x():int                { return _x;            }
        public function get y():int                { return _y;            }
        public function get length():int           { return _length;       }
        public function get isHorizontal():Boolean { return _isHorizontal; }
    }
}
