package N2P2.utils
{
    public class UserInfo
    {
        private var _id:Number;
        private var _clearInfo:Array;
        
        public function UserInfo()
        {
            _clearInfo = new Array(1600, 7200, 10500, 9700, 8000, 12000, 30100);
        }
        
        public function setPoint(point:int):void
        {
            _clearInfo.push(point);
        }
        
        public function parseUserInfoXml(xml:XML, stageNum:int):void
        {
            var userID:String = "0001";
            
            for each (var sub:XML in xml.user)
            {
                if(sub.attribute("id") == userID)
                {
                    _id        = parseFloat(sub.attribute("point1"));
                    _clearInfo = parseArray(sub.elements("clearInfo").toString());
                }
            }
            
            function parseArray(str:String):Array
            {
                var base:Array = str.split(",\r\n");
                var output:Array = new Array;
                
                for each(var i:String in base)
                {
                    output.push(i.split(","));
                }
                
                for(var k:int=0; k<8; k++)
                {
                    for(var j:int=0; j<8; j++) output[k][j] = Number(output[k][j]);
                }
                
                return output;
            }
        }
        
        public function get id():Number       { return _id;       }
        public function get clearInfo():Array { return _clearInfo }
        
        public function set id(value:Number):void       { _id        = value; }
        public function set clearInfo(value:Array):void { _clearInfo = value; }
    }
}
