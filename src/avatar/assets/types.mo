import Result "mo:base/Result";

import CanisterGeek "mo:canistergeek/canistergeek";

import Admins "../admins";
module Assets {

    public type Result<A,B> = Result.Result<A,B>;
    public type FilePath = Text;
    public type Tag = Text;

    public type File = {
        asset : Asset;
        meta : Meta;
    };

    public type Asset = {
        contentType : Text;
        payload : Blob;
    };
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
        record : [(FilePath, File)];
    };

    public type Interface = {
        
        // Get the UD before upgrading
        preupgrade : () -> UpgradeData;

        // Reinitialize the state of the module after upgrading.
        postupgrade : (data : ?UpgradeData) -> ();

        // Upload bytes into the buffer.
        upload : (bytes : [Nat8]) -> ();

        // Finalize the buffer into an asset.
        uploadFinalize: (contentType : Text, meta : Meta, filePath : FilePath) -> Result<(), Text>;

        // Clear the buffer.
        // @auth : admin
        uploadClear: () -> ();

        // Delete a file using the filePath.
        // @auth : admin
        delete: (filePath : FilePath) -> Result<(), Text>;

        // Retrieve an optional file using the filePath.
        getFile : (filePath : FilePath) -> ?File;

        // Retrieve a component using the layer and the name.
        getComponent : (name : Text, layerId : Nat) -> Result<Text, Text>;

        // Retrieves the aset manifest (all assets).
        getManifest : () -> [File];

        // Get the number of uploaded assets and the total size.
        getStats : () -> (count : Nat, size : Nat);

    };
}
