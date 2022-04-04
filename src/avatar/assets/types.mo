import Admins "../admins";
import CanisterGeek "mo:canistergeek/canistergeek";
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

    public type UpgradeData = {
        record : [(FilePath, Record)];
    };

    public type Interface = {
        
        // Upload bytes into the buffer.
        upload : (bytes : [Nat8]) -> ();

        // Finalize the buffer into an asset.
        uploadFinalize: (contentType : Text, meta : Meta, filePath : FilePath) -> Result<(), Text>;

        // Clear the buffer.
        // @auth : admin
        uploadClear: () -> ();

        // Retrieves the aset manifest (all assets).
        getManifest : () -> [Record];

        // Get the number of uploaded assets and the total size.
        getStats : () -> (count : Nat, size : Nat);

        // Get the UD before upgrading
        preupgrade : () -> UpgradeData;

        // Reinitialize the state of the module after upgrading.
        postupgrade : (data : ?UpgradeData) -> ();


    };
}
