package N2P2.utils
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.AssetManager;

    /**
     * Asset 파일들을 불러옵니다. 
     * @author 이종민
     */
    public class AssetLoader
    {
        // 싱글톤 관련 변수들
        private static var _instance:AssetLoader;
        private static var _creatingSingleton:Boolean = false;
        
        private var _assetManager:AssetManager = new AssetManager;;
        
        public function AssetLoader()
        {
            if (!_creatingSingleton){
                throw new Error("[AssetLoader] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():AssetLoader
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new AssetLoader();
                _creatingSingleton = false;
            }
            return _instance;
        }
    
        /**
         * 경로에 해당하는 이미지 파일을 불러옵니다.  
         * @param path 불러올 이미지 파일의 경로
         * @param onComplete 이미지가 로드되었을 때 불려질 콜백 함수
         * @param onProgress 이미지가 로드될 때 불려질 프로그래스 콜백 함수
         * @example 아래 코드를 참조해서 사용하세요
         * <listing version="3.0">
         * 
         * A.as
         * public function onProgress(event:Object):void{
         *      trace(event as Number);
         * }
         * public function onComplete(event:Object):void{
         *      var bmp:Bitmap = event as Bitmap;
         * }
         * 
         * AssetLoader.instance.loadImageTexture("res/texture.png", onComplete, onProgress);
         * 
         * </listing>
         */
        public function loadTextureAtlas(pathTexture:String, pathXml:String, name:String, onComplete:Function, onProgress:Function = null):void
        {
            var file:File = findFile(pathTexture);
            var fileStream:FileStream = new FileStream(); 
            fileStream.open(file, FileMode.READ);
            
            var bytes:ByteArray = new ByteArray();
            fileStream.readBytes(bytes);
            
            fileStream.close();
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            loader.loadBytes(bytes);

            function onLoaderProgress(event:ProgressEvent):void
            {
                if( onProgress != null )
                {
                    onProgress(event.bytesLoaded/event.bytesTotal * 100);
                }
            }
            
            function onLoaderComplete(event:Event):void
            {
                trace("onLoaderComplete" + pathTexture);
                
                _assetManager.addTextureAtlas(name, new TextureAtlas(Texture.fromBitmap(LoaderInfo(event.target).content as Bitmap), loadXML(pathXml)));
                
                onComplete();
            }
            
            function ioErrorHandler(event:IOErrorEvent):void
            {
                trace("Image Load error: " + event.target + " _ " + event.text );                  
            }
        }
        
        public function loadXML(path:String):XML
        {
            var file:File = findFile(path);
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            
            var xmlNode:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            return xmlNode;
        }
        
        /**
         * 디바이스 내부 저장소를 확인하여 File 객체를 리턴합니다. 
         */
        private function findFile(path:String):File
        {
            var file:File = File.applicationDirectory.resolvePath(path);
            if( file.exists )
                return file;
            
            file = File.applicationStorageDirectory.resolvePath(path);
            if( file.exists )
                return file;
            
            return null;
        }
        
        /**
         * AssetLoader 에 저장되어 있는 이미지를 삭제하면서 자원을 해제합니다. 
         */
        public function removeImage(path:String):void
        {
            var bmp:Bitmap = _assetMap[path];
            
            var bmpData:BitmapData = (_assetMap[path] as Bitmap).bitmapData;
            if( bmpData != null )
            {
                bmpData.dispose();
            }
            
            _assetMap[path] = null;
        }
        
        public function get assetManager():AssetManager { return _assetManager; }
    }
}