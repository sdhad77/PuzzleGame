package N2P2.utils
{
    import flash.geom.Point;

    public class CustomVector
    {
        private var _x:int;
        private var _y:int;
        private var _length:int
        private var _isHorizontal:Boolean;
        
        public function CustomVector(x:int, y:int, length:int, isHorizontal:Boolean)
        {
            _x = x;
            _y = y;
            _length = length;
            _isHorizontal = isHorizontal;
        }
        
        public function isCross(v1:CustomVector, result:Array):void
        {
            if(v1.x <= this.x && this.x <= (v1.x + v1.length -1) && this.y <= v1.y && v1.y <= (this.y + this.length -1)) result[result.length] = new Point(this.x, v1.y);
        }
        
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
