import Admins "../admins";
import Result "mo:base/Result";
module Assets {

    public type Result<A,B> = Result.Result<A,B>;
    public type FilePath = Text;

    public type Record = {
        asset : Asset;
        meta : Meta;
    };

    public type Asset = {
        contentType : Text;
        payload : Blob;
    };
    public type Tag = Text;
    public type Meta = {
        name : Text;
        description : Text;
        tags : [Tag];
        category : Category;
    };

    public type Category = {
        #AvatarComponent;
        #AccessoryComponent;
        #LegendaryCharacter;
    };

    public type State = {
        record : [(FilePath, Record)];
    };

    public type Dependencies = {
        _Admins : Admins.Admins;
    };

    public type Parameters = State and Dependencies;

    public type Interface = {
        
        // Upload bytes into the buffer.
        // @auth : admin
        upload : (caller : Principal, bytes : [Blob]) -> ();

        // Finalize the buffer into an asset.
        // @auth : admin
        uploadFinalize: (caller : Principal, contentType : Text, meta : Meta, filePath : FilePath) -> Result<(), Text>;

        // Clear the buffer.
        // @auth : admin
        uploadClear: (caller : Principal) -> ();



    };
}
