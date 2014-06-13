package N2P2
{
    public class EmbeddedAssets
    {
        [Embed(source="../../bin/res/system/ui.png")]
        public static const UISheet:Class;
        
        [Embed(source="../../bin/res/system/ui.xml", mimeType="application/octet-stream")]
        public static const UIXml:Class;
        
        [Embed(source="../../bin/res/system/inGameUI.png")]
        public static const inGameUISheet:Class;
        
        [Embed(source="../../bin/res/system/inGameUI.xml", mimeType="application/octet-stream")]
        public static const inGameUIXml:Class;
    }
}