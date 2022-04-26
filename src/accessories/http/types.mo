import HashMap "mo:base/HashMap";

import Accessory "../types/accessory";
import Admins "../admins";
import Items "../items";
module HTTP {

    type TokenIndex = Nat32;
    type Item = Accessory.Item;

    public type Dependencies = {
        _Admins : Admins.Admins;
        _Items : Items.Factory;
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