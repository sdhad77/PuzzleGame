package N2P2.utils
{
    public class EmbeddedAssets
    {
        [Embed(source="../../../bin/res/system/titleUI.png")]
        public static const titleUISheet:Class;
        
        [Embed(source="../../../bin/res/system/titleUI.xml", mimeType="application/octet-stream")]
        public static const titleUIXml:Class;
        
        [Embed(source="../../../bin/res/system/worldMapUI.png")]
        public static const worldMapUISheet:Class;
        
        [Embed(source="../../../bin/res/system/worldMapUI.xml", mimeType="application/octet-stream")]
        public static const worldMapUIXml:Class;
        
        [Embed(source="../../../bin/res/system/inGameUI.png")]
        public static const inGameUISheet:Class;
        
        [Embed(source="../../../bin/res/system/inGameUI.xml", mimeType="application/octet-stream")]
        public static const inGameUIXml:Class;
        
        [Embed(source="../../../bin/res/system/stageInfo.xml", mimeType="application/octet-stream")]
        public static const stageInfoXml:Class;
    }
}