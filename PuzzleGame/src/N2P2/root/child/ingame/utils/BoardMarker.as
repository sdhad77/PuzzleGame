package N2P2.root.child.ingame.utils
{
    import N2P2.utils.GlobalData;
    
    import starling.display.Sprite;

    public class BoardMarker
    {
        // 싱글톤 관련 변수들
        private static var _instance:BoardMarker;
        private static var _creatingSingleton:Boolean = false;
        
        public function BoardMarker()
        {
            if (!_creatingSingleton){
                throw new Error("[BoardMarker] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():BoardMarker
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new BoardMarker();
                _creatingSingleton = false;
            }
            return _instance;
        }
        
        /**
         * 특수 타일을 표시하는 함수
         * @param horizontalArr 가로 검사 결과가 저장된 배열
         * @param verticalArr 세로 검사 결과가 저장된 배열
         * @param crossResult 교차 검사 결과가 저장된 배열
         * @param tiles 타일 배열
         */
        public function markSpecialTile(horizontalArr:Array, verticalArr:Array, crossResult:Array, tiles:Vector.<Vector.<Tile>>):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                //길이가 5이상.. 유령 생성
                if(horizontalArr[i].length >= 5)
                {
                    tiles[horizontalArr[i].x][horizontalArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                //길이가 4.. 가로 제거 타일 생성
                else if(horizontalArr[i].length == 4)
                {
                    tiles[horizontalArr[i].x][horizontalArr[i].y].mark(tiles[horizontalArr[i].x][horizontalArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                //길이가 5이상.. 유령 생성
                if(verticalArr[i].length >= 5)
                {
                    tiles[verticalArr[i].x][verticalArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                //길이가 4.. 세로 제거 타일 생성
                else if(verticalArr[i].length == 4)
                {
                    tiles[verticalArr[i].x][verticalArr[i].y].mark(tiles[verticalArr[i].x][verticalArr[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<crossResult.length; i++)
            {
                //교차 하는 타일. 광범위 제거 타일 생성
                tiles[crossResult[i].x][crossResult[i].y].mark(tiles[crossResult[i].x][crossResult[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
            }
        }
        
        /**
         * 특수 타일을 표시하는 함수. swap시 사용하기 위해 개량한 함수(특수 타일 생성 위치 때문에)
         * @param currentTileX 현재 타일의 인덱스
         * @param currentTileY 현재 타일의 인덱스
         * @param newTileX 새로운 타일의 인덱스
         * @param newTileY 새로운 타일의 인덱스
         * @param hArr 가로 검사 결과가 저장된 배열
         * @param vArr 새로 검사 결과가 저장된 배열
         * @param cArr 교차 검사 결과가 저장된 배열
         * @param tiles 타일 배열
         */
        public function markSpecialTileForSwap(currentTileX:int, currentTileY:int, newTileX:int, newTileY:int, hArr:Array, vArr:Array, cArr:Array, tiles:Vector.<Vector.<Tile>>):void
        {
            for(var i:int=0; i<hArr.length; i++)
            {
                //길이가 5이상.. 유령 생성
                if(hArr[i].length >= 5)
                {
                    //타일이 생성될 위치 선정
                    if(hArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(GlobalData.TILE_GHOST);
                    else if(hArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(GlobalData.TILE_GHOST);
                    else tiles[hArr[i].x][hArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                //길이가 4.. 가로 제거 타일 생성
                else if(hArr[i].length == 4)
                {
                    //타일이 생성될 위치 선정
                    if(hArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                    else if(hArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                    else tiles[hArr[i].x][hArr[i].y].mark(tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<vArr.length; i++)
            {
                //길이가 5이상.. 유령 생성
                if(vArr[i].length >= 5)
                {
                    //타일이 생성될 위치 선정
                    if(vArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(GlobalData.TILE_GHOST);
                    else if(vArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(GlobalData.TILE_GHOST);
                    else tiles[vArr[i].x][vArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                //길이가 4.. 세로 제거 타일 생성
                else if(vArr[i].length == 4)
                {
                    //타일이 생성될 위치 선정
                    if(vArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                    else if(vArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                    else tiles[vArr[i].x][vArr[i].y].mark(tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<cArr.length; i++)
            {
                //교차 하는 타일. 광범위 제거 타일 생성
                tiles[cArr[i].x][cArr[i].y].mark(tiles[cArr[i].x][cArr[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
            }
        }
        
        /**
         * 힌트타일을 sprite에 등록하는 함수
         * @param arr 힌트타일의 인덱스가 저장된 배열
         * @param tiles 타일 배열
         * @param hintTiles 힌드타일이 저장될 sprite
         */
        public function markHint(arr:Array, tiles:Vector.<Vector.<Tile>>, hintTiles:Sprite):void
        {
            //기존 힌트 제거
            hintTiles.removeChildren();
            
            //새로운 힌트 등록
            for(var i:int=0; i<arr.length; i+=2)
            {
                hintTiles.addChild(new Tile(GlobalData.TILE_HINT));
                hintTiles.getChildAt(hintTiles.numChildren-1).x = tiles[arr[i]][arr[i+1]].x;
                hintTiles.getChildAt(hintTiles.numChildren-1).y = tiles[arr[i]][arr[i+1]].y;
            }
            
            arr.length = 0;
            arr = null;
        }
    }
}