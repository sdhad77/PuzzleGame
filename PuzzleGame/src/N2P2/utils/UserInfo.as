package N2P2.utils
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class UserInfo
    {
        private var _id:String;
        private var _clearInfo:Array;
        
        public function UserInfo()
        {
        }
        
        public function setPoint(stageNum:int, point:int):void
        {
            if((_clearInfo.length) == (stageNum-1))
            {
                _clearInfo.push(point);
     //           storeUserInfoXml();
            }
            else
            {
                if(_clearInfo[stageNum-1] < point)
                {
                    _clearInfo[stageNum-1] = point;
       //             storeUserInfoXml();
                }
            }
        }
        
        public function parseUserInfoXml(id:String, xml:XML):void
        {
            _id = id;
            
            for each (var sub:XML in xml.user)
            {
                if(sub.attribute("id") == _id)
                {
                    _clearInfo = parseArray(sub.elements("clearInfo").toString());
                }
            }
            
            function parseArray(str:String):Array
            {
                if(str == "")
                {
                    var output:Array = new Array;
                }
                else
                {
                    output = str.split(",");
                    
                    for(var i:int=0; i<output.length; i++)
                    {
                        output[i] = Number(output[i]);
                    }
                }
                
                return output;
            }
        }
        
        private function storeUserInfoXml():void
        {
            var xml:XML = new XML;
            xml = 
                <userInfo>
                </userInfo>;
            
            var newItem:XML = XML("<user id =" + "\"" + _id + "\" " + " />" + <clearInfo></clearInfo>);
            newItem.clearInfo = _clearInfo;
            
            xml.appendChild(newItem);
            
            var ba:ByteArray = new ByteArray();
            ba.writeUTFBytes(xml);
            
            var file:File = new File(File.applicationDirectory.resolvePath("system/userInfo.xml").nativePath);
            var fileStream:FileStream = new FileStream();
            
            fileStream.open(file, FileMode.WRITE);
            fileStream.writeUTFBytes(ba.toString());
            fileStream.close();
            
            ba.clear();
            ba = null;
            fileStream = null;
        }
        
        public function get id():String       { return _id;       }
        public function get clearInfo():Array { return _clearInfo }
        
        public function set id(value:String):void       { _id        = value; }
        public function set clearInfo(value:Array):void { _clearInfo = value; }
    }
}
