package N2P2.root.child.ingame.utils
{
    import N2P2.utils.CustomVector;
    import N2P2.utils.GlobalData;

    public class BoardChecker
    {
        public function checkHorizontal(index:int, tiles:Vector.<Vector.<Tile>>, result:Array):void
        {
            var cnt:int = 0;
            var tileChar:int = tiles[index][0].char;
            
            for(var i:int=0; i < GlobalData.FIELD_WIDTH; i++)
            {
                if(tiles[index][i].visible == true && tileChar == (tiles[index][i].char)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(index,i-cnt,cnt,true);
                    
                    cnt = 1;
                    tileChar = tiles[index][i].char;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(index,GlobalData.FIELD_WIDTH-cnt,cnt,true);
        }
        
        public function checkVertical(index:int, tiles:Vector.<Vector.<Tile>>, result:Array):void
        {
            var cnt:int = 0;
            var tileChar:int = tiles[0][index].char;
            
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++)
            {
                if(tiles[i][index].visible == true && tileChar == (tiles[i][index].char)) cnt++;
                else
                {
                    if(cnt >= 3) result[result.length] = new CustomVector(i-cnt,index,cnt,false);
                    
                    cnt = 1;
                    tileChar = tiles[i][index].char;
                }
            }
            
            if(cnt >= 3) result[result.length] = new CustomVector(GlobalData.FIELD_HEIGTH-cnt,index,cnt,false);
        }
        
        public function checkAll(horizontalArr:Array, verticalArr:Array, tiles:Vector.<Vector.<Tile>>):void
        {
            for(var i:int=0; i < GlobalData.FIELD_HEIGTH; i++) checkHorizontal(i, tiles, horizontalArr);
            for(i=0; i < GlobalData.FIELD_WIDTH; i++) checkVertical(i, tiles, verticalArr);
        }
        
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
                        if(tiles[i][j].char == tiles[i][j+1].char)
                        {
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
                        if(tiles[j][i].char == tiles[j+1][i].char)
                        {
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
        
        private function checkHintSpecialTile(tiles:Vector.<Vector.<Tile>>, result:Array):Array
        {
            for(var i:int=0; i<GlobalData.FIELD_HEIGTH; i++)
            {
                for(var j:int=0; j<GlobalData.FIELD_WIDTH-1; j++)
                {
                    if(tiles[i][j].visible == false || tiles[i][j].type == 0) continue;
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
                    if(tiles[j][i].visible == false || tiles[j][i].type == 0) continue;
                    if(tiles[j+1][i].visible == true && tiles[j+1][i].type != 0)
                    {
                        result = new Array(j,i,j+1,i);
                        return result;
                    }
                }
            }
            
            return result;
        }
        
        public function checkSwapTileIsSpecialTile(currentTileX:int, currentTileY:int, newTileX:int, newTileY:int, horizontalArr:Array, verticalArr:Array, tiles:Vector.<Vector.<Tile>>):Boolean
        {
            var tileType1:int = tiles[currentTileY][currentTileX].type;
            var tileChar1:int  = tiles[currentTileY][currentTileX].char;
            var tileType2:int = tiles[newTileY][newTileX].type;
            var tileChar2:int  = tiles[newTileY][newTileX].char;
            
            if(tileType1 == 0 && tileType2 == 4) ghost(currentTileY, currentTileX, tileChar1);
            if(tileType1 == 1 || tileType1 == 2)
            {
                if     (tileType2 == 1) cross(currentTileY, currentTileX, newTileY, newTileX);
                else if(tileType2 == 2) cross(currentTileY, currentTileX, newTileY, newTileX);
                else if(tileType2 == 3) crossX3(currentTileY, currentTileX);
                else if(tileType2 == 4) ghost(currentTileY, currentTileX, tileChar1);
                else return false;
            }
            else if(tileType1 == 3)
            {
                if     (tileType2 == 1) crossX3(newTileY, newTileX);
                else if(tileType2 == 2) crossX3(newTileY, newTileX);
                else if(tileType2 == 3) bigSunglasses(currentTileY, currentTileX);
                else if(tileType2 == 4) ghost(currentTileY, currentTileX, tileChar1);
                else return false;
            }
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