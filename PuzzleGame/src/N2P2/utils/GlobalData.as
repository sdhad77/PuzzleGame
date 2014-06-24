package N2P2.utils
{
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    public class GlobalData
    {
        public static const TEXTFIELD_MOVENUM_POS_X:Number = 0.126;
        public static const TEXTFIELD_MOVENUM_POS_Y:Number = 0.094;
        public static const TEXTFIELD_MOVENUM_SIZE:Number = 0.039;
        
        public static const TEXTFIELD_POINT_POS_X:Number = 0.170;
        public static const TEXTFIELD_POINT_POS_Y:Number = 0.094;
        public static const TEXTFIELD_POINT_SIZE:Number = 0.039;
        
        public static const INGAME_STAGE_SCALE:Number = 0.4;
        public static const FIELD_WIDTH:int = 8;
        public static const FIELD_HEIGTH:int = 8;
        
        public static const TILE_LENGTH:int = 160;
        public static const TILE_LENGTH_SCALED:Number = TILE_LENGTH * INGAME_STAGE_SCALE;
        public static const TILE_CHAR:int = 6;
        public static const TILE_TYPE_HORIZONTAL:int = 1;
        public static const TILE_TYPE_VERTICAL:int = 2;
        public static const TILE_TYPE_CROSS:int = 3;
        public static const TILE_TYPE_GHOST:int = 4;
        
        public static const TILE_GHOST:int = 24;
        
        public static const TWEEN_TIME:Number = 0.2;
        
        public static var TILE_TEXTURE:Vector.<Texture>;
        
        public function GlobalData(assetManager:AssetManager)
        {
            init(assetManager);
        }
        
        private function init(assetManager:AssetManager):void
        {
            TILE_TEXTURE = assetManager.getTextureAtlas("inGameUI").getTextures("character_");
        }
    }
}