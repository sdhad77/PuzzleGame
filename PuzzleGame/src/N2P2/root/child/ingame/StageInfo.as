package N2P2.root.child.ingame
{
    /**
     * 스테이지 정보를 읽어와서 가지고 있는 클래스입니다.</br>
     * 한개의 스테이지 정보만 가지고 있을 수 있습니다.
     * @author 신동환
     */
    public class StageInfo
    {
        private var _board:Array;        //타일이 표시되는 영역, 표시되지 않는 영역을 구분하기 위한 배열
        private var _boardForMove:Array; //타일이 생성가능한 라인인지 판별하기 위한 배열. 타일 생성이 불가능한 라인이면 대각선 이동을 통해 타일을 넘겨 받는다.
        private var _moveNum:int;        //이 스테이지의 타일 이동가능 횟수
        private var _point:int;          //현재 점수
        private var _point1:int;         //이 스테이지를 클리어하기 위한 점수(별 한 개)
        private var _point2:int;         //이 스테이지를 클리어하기 위한 점수(별 두 개)
        private var _point3:int;         //이 스테이지를 클리어하기 위한 점수(별 세 개)
        private var _missionType:int;    //이 스테이지의 미션
        
        /**
         * stage정보가 저장되어 있는 xml파일을 읽는 함수
         * @param xml stage정보가 저장되어있는 xml파일
         * @param stageNum 몇 스테이지인지
         */
        public function parseStageInfoXml(xml:XML, stageNum:int):void
        {
            var stageName:String = (stageNum < 10) ? "stage0" + stageNum.toString() : "stage" + stageNum.toString();
            
            for each (var subStage:XML in xml.stage)
            {
                if(subStage.attribute("name") == stageName)
                {
                    _board        = parseArray(subStage.elements("board").toString());
                    _boardForMove = parseArray(subStage.elements("boardForMove").toString());
                    _moveNum      = parseFloat(subStage.attribute("moveNum"));
                    _point        = 0;
                    _point1       = parseFloat(subStage.attribute("point1"));
                    _point2       = parseFloat(subStage.attribute("point2"));
                    _point3       = parseFloat(subStage.attribute("point3"));
                    _missionType  = parseFloat(subStage.attribute("missionType"));
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
        
        public function clear():void
        {
            if(_board != null)
            {
                while(_board.length > 0)
                {
                    _board[_board.length-1].length = 0;
                    _board.pop();
                }
                _board = null;
            }
            if(_boardForMove != null)
            {
                while(_boardForMove.length > 0)
                {
                    _boardForMove[_boardForMove.length-1].length = 0;
                    _boardForMove.pop();
                }
                _boardForMove = null;
            }
        }
        
        public function get board():Array        { return _board;        }
        public function get boardForMove():Array { return _boardForMove; }
        public function get moveNum():int        { return _moveNum;      }
        public function get point():int          { return _point;        }
        public function get point1():int         { return _point1;       }
        public function get point2():int         { return _point2;       }
        public function get point3():int         { return _point3;       }
        public function get missionType():int    { return _missionType;  }
        
        public function set board(value:Array):void        { _board        = value; }
        public function set boardForMove(value:Array):void { _boardForMove = value; }
        public function set moveNum(value:int):void        { _moveNum      = value; }
        public function set point(value:int):void          { _point        = value; }
        public function set point1(value:int):void         { _point1       = value; }
        public function set point2(value:int):void         { _point2       = value; }
        public function set point3(value:int):void         { _point3       = value; }
        public function set missionType(value:int):void    { _missionType  = value; }
    }
}