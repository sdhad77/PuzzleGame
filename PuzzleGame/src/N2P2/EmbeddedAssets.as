package N2P2
{
    public class EmbeddedAssets
    {
        [Embed(source="../../bin/res/system/ui.png")]
        public static const UISheet:Class;
        
        [Embed(source="../../bin/res/system/ui.xml", mimeType="application/octet-stream")]
        public static const UIXml:Class;
        
        [Embed(source="../../bin/res/character/char.png")]
        public static const CharSheet:Class;
        
        [Embed(source="../../bin/res/character/char.xml", mimeType="application/octet-stream")]
        public static const CharXml:Class;
        
        [Embed(source="../../bin/res/character/char2.png")]
        public static const Char2Sheet:Class;
        
        [Embed(source="../../bin/res/character/char2.xml", mimeType="application/octet-stream")]
        public static const Char2Xml:Class;
    }
}