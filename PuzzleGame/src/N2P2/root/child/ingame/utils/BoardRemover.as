package N2P2.root.child.ingame.utils
{
    import N2P2.utils.GlobalData;

    public class BoardRemover
    {
        /**
         * 특정 타일을 화면에서 안보이게함 (visible false)
         * @param idx1 인덱스1
         * @param idx2 인덱스2
         * @param tiles 제거할 타일의 타일 배열
         * @param stageInfo 점수를 증가시키기 위해 stageInfo가 필요함
         * @return 특수 타일일 경우 true 반환
         */
        public function removeTile(idx1:int, idx2:int, tiles:Vector.<Vector.<Tile>>, stageInfo:StageInfo):Boolean
        {
            //타일 하나에 100점
            if(tiles[idx1][idx2].visible == true) stageInfo.point += GlobalData.TILE_POINT;
            return tiles[idx1][idx2].vanishFromBoard();
        }
        
        /**
         * 제거된 타일이 특수타일일 경우 호출되는 함수
         * @param idx1 인덱스1
         * @param idx2 인덱스2
         * @param tiles 제거할 타일의 타일 배열
         * @param stageInfo 점수를 증가시키기 위해 stageInfo가 필요함
         */
        public function removeSpecialTile(idx1:int, idx2:int, tiles:Vector.<Vector.<Tile>>, stageInfo:StageInfo):void
        {
            var tileType:int = tiles[idx1][idx2].type;
            
            //타입 0 일반, 타입 1 가로, 타입 2 세로, 타입 3 광범위, 타입 4 유령
            if     (tileType == 1) horizontalTile(idx1);
            else if(tileType == 2) verticalTile  (idx2);
            else if(tileType == 3) sunglassesTile(idx1, idx2);
            else if(tileType == 4) ghostTile(Math.floor((Math.random())*GlobalData.TILE_CHAR));
            else trace("특수타일 버그발생");
            
            function horizontalTile(idx:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_WIDTH; i++) if(removeTile(idx, i, tiles, stageInfo)) removeSpecialTile(idx,i,tiles, stageInfo);
            }
            function verticalTile(idx:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++) if(removeTile(i, idx, tiles, stageInfo)) removeSpecialTile(idx,i,tiles, stageInfo);
            }
            function sunglassesTile(idx1:int, idx2:int):void
            {
                for(var i:int=idx1-2; i<=idx1+2; i++)
                {
                    if(i < 0) continue;
                    if(i >= GlobalData.FIELD_HEIGTH) break;
                    
                    if(i == idx1-2 || i == idx1+2)
                    {
                        for(var j:int=idx2-1; j<=idx2+1; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            if(removeTile(i, j, tiles, stageInfo)) removeSpecialTile(i,j,tiles, stageInfo);
                        }
                    }
                    else
                    {
                        for(j=idx2-2; j<=idx2+2; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            if(removeTile(i,j, tiles, stageInfo)) removeSpecialTile(i,j,tiles, stageInfo);
                        }
                    }
                }
            }
            function ghostTile(tileChar:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
                {
                    for(var j:int=0; j<GlobalData.FIELD_WIDTH; j++)
                    {
                        if((tiles[i][j].char) == tileChar) if(removeTile(i,j, tiles, stageInfo)) removeSpecialTile(i,j,tiles, stageInfo);
                    }
                }
            }
        }
        
        /**
         * 모든 타일을 화면에서 안보이게 함
         * @param tiles 타일 배열
         */
        public function removeAllTile(tiles:Vector.<Vector.<Tile>>):void
        {
            for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
            {
                for(var j:int=0; j<GlobalData.FIELD_WIDTH; j++)
                {
                    tiles[i][j].vanishFromBoard();
                }
            }
        }
        
        /**
         * 마크된 타일들을 화면에서 안보이게 함
         * @param horizontalArr 가로 검사 결과가 저장되어있는 배열
         * @param verticalArr 세로 검사 결과가 저장되어있는 배열
         * @param tiles 타일 배열
         * @param stageInfo 점수를 증가시키기 위해 stageInfo가 필요함
         */
        public function removeMarkTile(horizontalArr:Array, verticalArr:Array, tiles:Vector.<Vector.<Tile>>, stageInfo:StageInfo):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                for(var offset:int=0; offset < horizontalArr[i].length; offset++)
                {
                    if(removeTile(horizontalArr[i].x, horizontalArr[i].y + offset, tiles, stageInfo))
                        removeSpecialTile(horizontalArr[i].x, horizontalArr[i].y + offset, tiles, stageInfo);
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                for(offset=0; offset < verticalArr[i].length; offset++)
                {
                    if(removeTile(verticalArr[i].x + offset, verticalArr[i].y, tiles, stageInfo)) 
                        removeSpecialTile(verticalArr[i].x + offset, verticalArr[i].y, tiles, stageInfo);
                }
            }
        }
    }
}