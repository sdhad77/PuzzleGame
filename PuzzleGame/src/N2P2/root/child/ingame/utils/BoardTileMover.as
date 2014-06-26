package N2P2.root.child.ingame.utils
{
    import com.greensock.TweenLite;
    
    import N2P2.utils.GlobalData;

    public class BoardTileMover
    {
        /**
         * 타일을 빈자리로 이동시키는 함수</br>
         * 좌하에서 우,상으로 진행하면서 검사함
         * @param tiles 타일 배열
         * @param stageInfo 게임 스테이지 정보
         * @param func 업데이트 함수
         */
        public function moveTiles(tiles:Vector.<Vector.<Tile>>, stageInfo:StageInfo, func:Function):void
        {
            var moveTileExist:Boolean = false;
            
            for(var j:int=GlobalData.FIELD_HEIGTH-1; 0 <= j; j--)
            {
                for(var i:int=0; i < GlobalData.FIELD_WIDTH; i++)
                {
                    if(tiles[j][i].visible == false && stageInfo.board[j][i] == 0)
                    {
                        //제일 위에 있는 행일 경우. 무조건 바로 위에서 내려옴
                        if(j == 0)
                        {
                            tiles[j][i].mark(Math.floor((Math.random())*GlobalData.TILE_CHAR));
                            tiles[j][i].moveFrom(null, "-160");
                            moveTileExist = true;
                        }
                        else
                        {
                            //바로위에 있는 타일이 있을 경우
                            if(tiles[j-1][i].visible == true)
                            {
                                tiles[j][i].mark(tiles[j-1][i].num);
                                tiles[j][i].moveFrom(null, "-160");
                                tiles[j-1][i].visible = false;
                            }
                            //이 타일의 가장 위에 있는 타일이 타일을 생성할수 없는 것이면. (대각선 이동때문)
                            else if(stageInfo.boardForMove[j][i] == 1)
                            {
                                //좌상의 타일이 있을 경우
                                if(i != 0 && tiles[j-1][i-1].visible == true && tiles[j][i-1].visible == true)
                                {
                                    tiles[j][i].mark(tiles[j-1][i-1].num);
                                    tiles[j][i].moveFrom("-160", "-160");
                                    tiles[j-1][i-1].visible = false;
                                }
                                //우상의 타일이 있을 경우
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
            
            //움직일수 있는 타일이 있었으면 잠시후에 다시 이 함수 호출하여 움직일수 있는지 검사
            if(moveTileExist == true) TweenLite.delayedCall(GlobalData.TWEEN_TIME, moveTiles, new Array(tiles, stageInfo, func));
            else func();
        }
    }
}