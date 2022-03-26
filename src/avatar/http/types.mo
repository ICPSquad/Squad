import Admins "../admins";
import Assets "../assets";

module HTTP {

    public type Dependencies = {
        _Admins : Admins.Admins;
        _Assets : Assets.Assets;
    };

    public type HeaderField = (Text,Text);
    
    public type StreamingStrategy = {
        #Callback: {
            callback : StreamingCallback;
            token    : StreamingCallbackToken;
        };
    };
    public type StreamingCallback = query (StreamingCallbackToken) -> async (StreamingCallbackResponse);
    public type StreamingCallbackToken =  {
        content_encoding : Text;
        index            : Nat;
        key              : Text;
    };
    public type StreamingCallbackResponse = {
        body  : Blob;
        token : ?StreamingCallbackToken;
    };

    public type Request = {
        body    : Blob;
        headers : [HeaderField];
        method  : Text;
        url     : Text;
    };
    public type Response = {
        body : Blob;
        headers : [HeaderField];
        streaming_strategy : ?StreamingStrategy;
        status_code : Nat16;
    };
}