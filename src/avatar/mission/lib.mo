import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Text "mo:base/Text";

import Ext "mo:ext/Ext";

import Types "types";

module {
    public class Factory(dependencies : Types.Dependencies) : Types.Interface {

        
        type TokenIndex = Ext.TokenIndex;
        type TokenIdentifier = Ext.TokenIdentifier;

        let _Logs = dependencies._Logs;
        let _Ext = dependencies._Ext;
        let _Avatar = dependencies._Avatar;

        ///////////////
        // API ///////
        //////////////

        public func verifyMission(id : Nat, caller : Principal) : Bool {
            for((number, handler) in Iter.fromArray(missions)){
                if(id == number ){
                    return handler(caller);
                };
            };
            _Logs.logMessage("verifyMission :: ERR :: No handler found for mission " # Nat.toText(id));
            return false;
        };

        ///////////////
        // Missions //
        //////////////
        
        /* 
            This function is used to validate mission with id 0. 
            Returns a boolean indicating if at least one of the avatar owned by the caller is equipped with an accessory.
        */
        func _isAccessoryEquipped(caller : Principal) : Bool {
            let account = Text.map(Ext.AccountIdentifier.fromPrincipal(caller, null), Prim.charToLower);
            switch(_Ext.tokens(account)){
                case(#err(_)) {
                    _Logs.logMessage("isAccessory Equipped :: ERR :: _Ext.tokens");
                    return false;
                };
                case(#ok(tokens)) {
                    let tokensId = Array.map<TokenIndex, TokenIdentifier>(tokens, func(x) { Ext.TokenIdentifier.encode(dependencies.cid, x)});
                    for(token in tokensId.vals()){
                        if(_Avatar.isEquipped(token)){
                            return true;
                        };
                    };
                    return false;
                };
            };
        };

        ////////////
        // State //
        ///////////

        /* 
            Associate id with the name of the function that will process the verification of the mission.
        */

        let missions : [(Nat, (caller : Principal) -> Bool)] = [
            (0, _isAccessoryEquipped),
        ];
    
    };
}