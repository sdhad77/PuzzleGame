package N2P2 
{
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.TouchEvent;
    import starling.utils.AssetManager;

    public class InGame extends Sprite
    {
        private var image:Image;
        
        public function InGame()
        {
            super();
        }
        
        public function start(assetManager:AssetManager):void
        {
            drawGame(assetManager);
        }
        
        private function drawGame(assetManager:AssetManager):void
        {
            image = new Image(assetManager.getTextureAtlas("char2").getTexture("ani_0.png"));
            image.addEventListener(starling.events.TouchEvent.TOUCH, clicked);
            addChild(image);
            
            function clicked():void
            {
                trace("aa");
            }
        }
    }
}