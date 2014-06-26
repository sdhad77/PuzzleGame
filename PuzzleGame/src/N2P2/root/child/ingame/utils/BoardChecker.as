package N2P2.root.child.ingame.utils
{
    import N2P2.utils.CustomVector;
    import N2P2.utils.GlobalData;

    public class BoardChecker
    {
        /**
         * 보드의 행을 검사하는 함수
         * @param index 검사할 행의 번호
         * @param tiles 검사할 보드의 타일 배열
         * @param result 검사 결과
         */
        public function checkHorizontal(index:int, tiles:Vector.<Vector.<Tile>>, result:Array):void
        {
            var cnt:int = 0;
            var tileChar:int = tiles[index][0].char;
            
            for(var i:int=0; i < GlobalData.FIELD_WIDTH; i++)
            {
                //보이는 상태이고, 이전 타일과 현재 타일의 char가 같으면
                if(tiles[index][i].visible == true && tileChar == (tiles[index][i].char)) cnt++;
                else
                {
                    //연속되는 타일이 3개 이상일 경우 결과에 저장시킴
                    if(cnt >= 3) result[result.length] = new CustomVector(index,i-cnt,cnt,true);
                    
                    cnt = 1;
                    tileChar = tiles[index][i].char;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(index,GlobalData.FIELD_WIDTH-cnt,cnt,true);
        }
        
        /**
         * 보드의 열을 검사하는 함수
         * @param index 검사할 열의 번호
         * @param tiles 검사할 보드의 타일 배열
         * @param result 검사 결과
         */
        public function checkVertical(index:int, tiles:Vector.<Vector.<Tile>>, result:Array):void
        {
            var cnt:int = 0;
            var tileChar:int = tiles[0][index].char;
            
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++)
            {
                //보이는 상태이고, 이전 타일과 현재 타일의 char가 같으면
                if(tiles[i][index].visible == true && tileChar == (tiles[i][index].char)) cnt++;
                else
                {
                    //연속되는 타일이 3개 이상일 경우 결과에 저장시킴
                    if(cnt >= 3) result[result.length] = new CustomVector(i-cnt,index,cnt,false);
                    
                    cnt = 1;
                    tileChar = tiles[i][index].char;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(GlobalData.FIELD_HEIGTH-cnt,index,cnt,false);
        }
        
        /**
         * 모든 행과 열을 검사하는 함수
         * @param horizontalArr 검사결과를 저장할 배열
         * @param verticalArr 검사결과를 저장할 배열
         * @param tiles 검사할 보드의 타일 배열
         */
        public function checkAll(horizontalArr:Array, verticalArr:Array, tiles:Vector.<Vector.<Tile>>):void
        {
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++) checkHorizontal(i, tiles, horizontalArr);
            for(i=0; i < GlobalData.FIELD_WIDTH; i++) checkVertical(i, tiles, verticalArr);
        }
        
        /**
         * 행,열이 겹치는 타일이 있는지 검사하는 함수
         * @param horizontalArr 행 검사결과
         * @param verticalArr 열 검사결과
         * @param result 겹치는 타일 검사결과
         */
        public function checkCross(horizontalArr:Array, verticalArr:Array, result:Array):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                for(var j:int=0; j<verticalArr.length; j++)
                {
                    horizontalArr[i].isCross(verticalArr[j], result);
                }
            }
        }
        
        /**
         * 맞출수 있는 타일이 있는지 검사하는 함수
         * @param tiles 검사할 타일 배열
         * @return 힌트 타일의 인덱스들
         */
        public function checkHint(tiles:Vector.<Vector.<Tile>>):Array
        {
            var result:Array = null;
            
            for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
            {
                for(var j:int=0; j<GlobalData.FIELD_WIDTH-1; j++)
                {
                    if(tiles[i][j].visible == false) continue;
                    if(tiles[i][j+1].visible == true)
                    {
                        //연속된 두 타일이 있을 경우
                        if(tiles[i][j].char == tiles[i][j+1].char)
                        {
                            //두 타일 기준으로 좌상, 좌, 좌하, 우상, 우, 우하를 검사하여 swap해서 사라질 타일이 있는지 검사
                            if(j+2 < GlobalData.FIELD_WIDTH && tiles[i][j+2].visible == true)
                            {
                                if     (j+3 < GlobalData.FIELD_WIDTH  && tiles[i][j+3].visible   == true && tiles[i][j].char == tiles[i][j+3].char)   return new Array(i,j,i,j+1,i,j+3);
                                else if(i-1 >= 0                      && tiles[i-1][j+2].visible == true && tiles[i][j].char == tiles[i-1][j+2].char) return new Array(i,j,i,j+1,i-1,j+2);
                                else if(i+1 < GlobalData.FIELD_HEIGTH && tiles[i+1][j+2].visible == true && tiles[i][j].char == tiles[i+1][j+2].char) return new Array(i,j,i,j+1,i+1,j+2);
                            }
                            else if(j-1 >= 0 && tiles[i][j-1].visible == true)
                            {
                                if     (j-2 >= 0                      && tiles[i][j-2].visible   == true && tiles[i][j].char == tiles[i][j-2].char)   return new Array(i,j,i,j+1,i,j-2);
                                else if(i-1 >= 0                      && tiles[i-1][j-1].visible == true && tiles[i][j].char == tiles[i-1][j-1].char) return new Array(i,j,i,j+1,i-1,j-1);
                                else if(i+1 < GlobalData.FIELD_HEIGTH && tiles[i+1][j-1].visible == true && tiles[i][j].char == tiles[i+1][j-1].char) return new Array(i,j,i,j+1,i+1,j-1);
                            }
                        }
                        //한칸 건너서 같은 타일이 있을 경우
                        else if(j+2 < GlobalData.FIELD_WIDTH && tiles[i][j+2].visible == true && tiles[i][j].char == tiles[i][j+2].char)
                        {
                            if     (i+1 < GlobalData.FIELD_HEIGTH && tiles[i+1][j+1].visible == true && tiles[i][j].char == tiles[i+1][j+1].char) return new Array(i,j,i,j+2,i+1,j+1);
                            else if(i-1 >= 0                      && tiles[i-1][j+1].visible == true && tiles[i][j].char == tiles[i-1][j+1].char) return new Array(i,j,i,j+2,i-1,j+1);
                        }
                    }
                }
            }
            
            for(i=0; i<GlobalData.FIELD_WIDTH; i++)
            {
                for(j=0; j<GlobalData.FIELD_HEIGTH-1; j++)
                {
                    if(tiles[j][i].visible == false) continue;
                    if(tiles[j+1][i].visible == true)
                    {
                        //연속된 두 타일이 있을 경우
                        if(tiles[j][i].char == tiles[j+1][i].char)
                        {
                            //두 타일 기준으로 좌상, 상, 우상, 좌하, 하 ,우하를 검사하여 swap해서 사라질 타일이 있는지 검사
                            if(j+2 < GlobalData.FIELD_HEIGTH && tiles[j+2][i].visible == true)
                            {
                                if     (j+3 < GlobalData.FIELD_HEIGTH && tiles[j+3][i].visible   == true && tiles[j][i].char == tiles[j+3][i].char)   return new Array(j,i,j+1,i,j+3,i);
                                else if(i-1 >= 0                      && tiles[j+2][i-1].visible == true && tiles[j][i].char == tiles[j+2][i-1].char) return new Array(j,i,j+1,i,j+2,i-1);
                                else if(i+1 < GlobalData.FIELD_WIDTH  && tiles[j+2][i+1].visible == true && tiles[j][i].char == tiles[j+2][i+1].char) return new Array(j,i,j+1,i,j+2,i+1);
                            }
                            else if(j-1 >= 0 && tiles[j-1][i].visible == true)
                            {
                                if     (j-2 >= 0                     && tiles[j-2][i].visible   == true && tiles[j][i].char == tiles[j-2][i].char)   return new Array(j,i,j+1,i,j-2,i);
                                else if(i-1 >= 0                     && tiles[j-1][i-1].visible == true && tiles[j][i].char == tiles[j-1][i-1].char) return new Array(j,i,j+1,i,j-1,i-1);
                                else if(i+1 < GlobalData.FIELD_WIDTH && tiles[j-1][i+1].visible == true && tiles[j][i].char == tiles[j-1][i+1].char) return new Array(j,i,j+1,i,j-1,i+1);
                            }
                        }
                        //한칸 건너서 같은 타일이 있을 경우
                        else if(j+2 < GlobalData.FIELD_WIDTH && tiles[j+2][i].visible == true && tiles[j][i].char == tiles[j+2][i].char)
                        {
                            if     (i+1 < GlobalData.FIELD_WIDTH  && tiles[j+1][i+1].visible == true && tiles[j][i].char == tiles[j+1][i+1].char) return new Array(j,i,j+2,i,j+1,i+1);
                            else if(i-1 >= 0                      && tiles[j+1][i-1].visible == true && tiles[j][i].char == tiles[j+1][i-1].char) return new Array(j,i,j+2,i,j+1,i-1);
                        }
                    }
                }
            }
            
            return checkHintSpecialTile(tiles, result);
        }
        
        /**
         * 일반 타일 중에서 swap 가능한 타일이 없을경우 특수타일들을 검사합니다.
         * @param tiles 검사할 보드의 타일배열
         * @param result 힌트 타일의 인덱스들
         * @return result
         */
        private function checkHintSpecialTile(tiles:Vector.<Vector.<Tile>>, result:Array):Array
        {
            for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
            {
                for(var j:int=0; j<GlobalData.FIELD_WIDTH-1; j++)
                {
                    //현재 타일이 특수 타일이 아니면 continue
                    if(tiles[i][j].visible == false || tiles[i][j].type == 0) continue;
                    //옆에 있는 타일이 툭수타일 일경우
                    if(tiles[i][j+1].visible == true && tiles[i][j+1].type != 0)
                    {
                        result = new Array(i,j,i,j+1);
                        return result;
                    }
                }
            }
            
            for(i=0; i<GlobalData.FIELD_WIDTH; i++)
            {
                for(j=0; j<GlobalData.FIELD_HEIGTH-1; j++)
                {
                    //현재 타일이 특수 타일이 아니면 continue
                    if(tiles[j][i].visible == false || tiles[j][i].type == 0) continue;
                    //아래에 있는 타일이 툭수타일 일경우
                    if(tiles[j+1][i].visible == true && tiles[j+1][i].type != 0)
                    {
                        result = new Array(j,i,j+1,i);
                        return result;
                    }
                }
            }
            
            return result;
        }
        
        /**
         * 타일 swap시 두 타일들이 특수타일인지 검사하는 함수
         * @param currentTileX 현재 타일
         * @param currentTileY 현재 타일
         * @param newTileX 새로 터치된 타일
         * @param newTileY 새로 터치된 타일
         * @param horizontalArr 결과물이 저장될 배열
         * @param verticalArr 결과물이 저장될 배열
         * @param tiles 검사할 보드의 타일 배열
         * @return 특수 타일들이면 true, 아니면 false
         */
        public function checkSwapTileIsSpecialTile(currentTileX:int, currentTileY:int, newTileX:int, newTileY:int, horizontalArr:Array, verticalArr:Array, tiles:Vector.<Vector.<Tile>>):Boolean
        {
            var tileType1:int = tiles[currentTileY][currentTileX].type;
            var tileChar1:int  = tiles[currentTileY][currentTileX].char;
            var tileType2:int = tiles[newTileY][newTileX].type;
            var tileChar2:int  = tiles[newTileY][newTileX].char;
            
            //일반 타일과 유령 타일이 만난것이면
            if(tileType1 == 0 && tileType2 == 4) ghost(currentTileY, currentTileX, tileChar1);
            //가로,세로 제거 타일 일 경우
            if(tileType1 == 1 || tileType1 == 2)
            {
                if     (tileType2 == 1) cross(currentTileY, currentTileX, newTileY, newTileX);
                else if(tileType2 == 2) cross(currentTileY, currentTileX, newTileY, newTileX);
                else if(tileType2 == 3) crossX3(currentTileY, currentTileX);
                else if(tileType2 == 4) ghost(currentTileY, currentTileX, tileChar1);
                else return false;
            }
            //광범위 제거 타일 일 경우
            else if(tileType1 == 3)
            {
                if     (tileType2 == 1) crossX3(newTileY, newTileX);
                else if(tileType2 == 2) crossX3(newTileY, newTileX);
                else if(tileType2 == 3) bigSunglasses(currentTileY, currentTileX);
                else if(tileType2 == 4) ghost(currentTileY, currentTileX, tileChar1);
                else return false;
            }
            //유령 타일 일 경우
            else if(tileType1 == 4)
            {
                ghost(newTileY, newTileX, tileChar2);
            }
            else return false;
            
            return true;
            
            function cross(idx1:int, idx2:int, idx3:int, idx4:int):void
            {
                tiles[idx1][idx2].changeType(GlobalData.TILE_TYPE_HORIZONTAL);
                tiles[idx3][idx4].changeType(GlobalData.TILE_TYPE_VERTICAL);
                
                horizontalArr[horizontalArr.length] = new CustomVector(idx1,idx2,1,true);
                verticalArr[verticalArr.length] = new CustomVector(idx3,idx4,1,false);
            }
            function crossX3(idx1:int, idx2:int):void
            {
                var cnt:int;
                
                for(var i:int=idx1-1; i<=idx1+1; i++)
                {
                    if(i < 0) continue;
                    if(i >= GlobalData.FIELD_HEIGTH) break;
                    
                    cnt = i;
                    
                    for(var j:int=idx2-1; j<=idx2+1; j++)
                    {
                        if(j < 0) continue;
                        if(j >= GlobalData.FIELD_WIDTH) break;
                        
                        if(cnt%2 == 0)
                        {
                            tiles[i][j].changeType(GlobalData.TILE_TYPE_HORIZONTAL);
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                        else
                        {
                            tiles[i][j].changeType(GlobalData.TILE_TYPE_VERTICAL);
                            verticalArr[verticalArr.length] = new CustomVector(i,j,1,false);
                        }
                        
                        cnt++;
                    }
                }
            }
            function bigSunglasses(idx1:int, idx2:int):void
            {
                for(var i:int=idx1-3; i<=idx1+3; i++)
                {
                    if(i < 0) continue;
                    if(i >= GlobalData.FIELD_HEIGTH) break;
                    
                    if(i == idx1-3 || i == idx1+3)
                    {
                        for(var j:int=idx2-2; j<=idx2+2; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                    else
                    {
                        for(j=idx2-3; j<=idx2+3; j++)
                        {
                            if(j < 0) continue;
                            if(j >= GlobalData.FIELD_WIDTH) break;
                            
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                }
            }
            function ghost(idx1:int, idx2:int, tileChar:int):void
            {
                for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
                {
                    for(var j:int=0; j<GlobalData.FIELD_WIDTH; j++)
                    {
                        if((tiles[i][j].char) == tileChar)
                        {
                            tiles[i][j].change(tiles[idx1][idx2].num);
                            horizontalArr[horizontalArr.length] = new CustomVector(i,j,1,true);
                        }
                    }
                }
            }
        }
    }
}