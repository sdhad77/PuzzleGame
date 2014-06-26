package N2P2.root.child.ingame.utils
{
    import N2P2.utils.GlobalData;
    
    import starling.display.Sprite;

    public class BoardMarker
    {
        public function markSpecialTile(horizontalArr:Array, verticalArr:Array, crossResult:Array, tiles:Vector.<Vector.<Tile>>):void
        {
            for(var i:int=0; i<horizontalArr.length; i++)
            {
                if(horizontalArr[i].length >= 5)
                {
                    tiles[horizontalArr[i].x][horizontalArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(horizontalArr[i].length == 4)
                {
                    tiles[horizontalArr[i].x][horizontalArr[i].y].mark(tiles[horizontalArr[i].x][horizontalArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<verticalArr.length; i++)
            {
                if(verticalArr[i].length >= 5)
                {
                    tiles[verticalArr[i].x][verticalArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(verticalArr[i].length == 4)
                {
                    tiles[verticalArr[i].x][verticalArr[i].y].mark(tiles[verticalArr[i].x][verticalArr[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<crossResult.length; i++)
            {
                tiles[crossResult[i].x][crossResult[i].y].mark(tiles[crossResult[i].x][crossResult[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
            }
        }
        
        public function markSpecialTileForSwap(currentTileX:int, currentTileY:int, newTileX:int, newTileY:int, hArr:Array, vArr:Array, cArr:Array, tiles:Vector.<Vector.<Tile>>):void
        {
            for(var i:int=0; i<hArr.length; i++)
            {
                if(hArr[i].length >= 5)
                {
                    if(hArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(GlobalData.TILE_GHOST);
                    else if(hArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(GlobalData.TILE_GHOST);
                    else tiles[hArr[i].x][hArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(hArr[i].length == 4)
                {
                    if(hArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                    else if(hArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                    else tiles[hArr[i].x][hArr[i].y].mark(tiles[hArr[i].x][hArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<vArr.length; i++)
            {
                if(vArr[i].length >= 5)
                {
                    if(vArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(GlobalData.TILE_GHOST);
                    else if(vArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(GlobalData.TILE_GHOST);
                    else tiles[vArr[i].x][vArr[i].y].mark(GlobalData.TILE_GHOST);
                }
                else if(vArr[i].length == 4)
                {
                    if(vArr[i].isExist(currentTileY, currentTileX)) tiles[currentTileY][currentTileX].mark(tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                    else if(vArr[i].isExist(newTileY, newTileX)) tiles[newTileY][newTileX].mark(tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                    else tiles[vArr[i].x][vArr[i].y].mark(tiles[vArr[i].x][vArr[i].y].char+GlobalData.TILE_CHAR);
                }
            }
            
            for(i=0; i<cArr.length; i++)
            {
                tiles[cArr[i].x][cArr[i].y].mark(tiles[cArr[i].x][cArr[i].y].char+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR+GlobalData.TILE_CHAR);
            }
        }
        
        public function markHint(arr:Array, tiles:Vector.<Vector.<Tile>>, hintTiles:Sprite):void
        {
            hintTiles.removeChildren();
            
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