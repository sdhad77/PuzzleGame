package N2P2.root.child.ingame.utils
{
    import com.greensock.TweenLite;
    
    import N2P2.utils.GlobalData;

    public class BoardTileMover
    {
        public function moveTiles(tiles:Vector.<Vector.<Tile>>, stageInfo:StageInfo, func:Function):void
        {
            var moveTileExist:Boolean = false;
            
            for(var j:int=GlobalData.FIELD_HEIGTH-1; 0 <= j; j--)
            {
                for(var i:int=0; i < GlobalData.FIELD_WIDTH; i++)
                {
                    if(tiles[j][i].visible == false && stageInfo.board[j][i] == 0)
                    {
                        if(j == 0)
                        {
                            tiles[j][i].mark(Math.floor((Math.random())*GlobalData.TILE_CHAR));
                            tiles[j][i].moveFrom(null, "-160");
                            moveTileExist = true;
                        }
                        else
                        {
                            if(tiles[j-1][i].visible == true)
                            {
                                tiles[j][i].mark(tiles[j-1][i].num);
                                tiles[j][i].moveFrom(null, "-160");
                                tiles[j-1][i].visible = false;
                            }
                            else if(stageInfo.boardForMove[j][i] == 1)
                            {
                                if(i != 0 && tiles[j-1][i-1].visible == true && tiles[j][i-1].visible == true)
                                {
                                    tiles[j][i].mark(tiles[j-1][i-1].num);
                                    tiles[j][i].moveFrom("-160", "-160");
                                    tiles[j-1][i-1].visible = false;
                                }
                                else if(i != (GlobalData.FIELD_WIDTH-1) && tiles[j-1][i+1].visible == true && tiles[j][i+1].visible == true)
                                {
                                    tiles[j][i].mark(tiles[j-1][i+1].num);
                                    tiles[j][i].moveFrom("160", "-160");
                                    tiles[j-1][i+1].visible = false;
                                }
                                else continue;
                            }
                            else continue;
                            
                            moveTileExist = true;
                        }
                    }
                }
            }
            
            if(moveTileExist == true) TweenLite.delayedCall(GlobalData.TWEEN_TIME, moveTiles, new Array(tiles, stageInfo, func));
            else func();
        }
    }
}