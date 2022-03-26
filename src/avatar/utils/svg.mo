import Text "mo:base/Text";

module {

    let SVG_LEADING_PATTERN : Pattern = #text("<svg xmlns=\"http://www.w3.org/2000/svg\">");
    let SVG_TRAILING_PATTERN : Pattern = #text("</svg>");

    public func getTextualComponent(svg : Blob) ->  {
        switch(Text.decodeUtf8(svg)){
            case(null) return #err;
            case(? svg_textual){
                return(Text.trimEnd(Text.trimEnd(svg_textual, SVG_LEADING_PATTERN), SVG_TRAILING_PATTERN));
            };
        };
    };

}