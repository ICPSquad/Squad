module {

    public type HeaderField = (Text, Text);

    public type HttpRequest = {
        url : Text;
        method : Text;
        body : Blob;
        headers : [HeaderField];
    };

    public type HttpResponse = {
        body : Blob;
        headers : [HeaderField];
        streaming_strategy : ?HttpStreamingStrategy;
        status_code : Nat16;
    };

    public type HttpStreamingStrategy = {
        #Callback: {
            callback : StreamingCallback; 
            token : StreamingCallbackToken;
        }
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



}