// import Date "mo:canistergeek/dateModule";
// import Time "mo:base/Time";
// import Int "mo:base/Int";
// import Hash "mo:base/Hash";
// import Iter "mo:base/Iter";
// import TrieMap "mo:base/TrieMap";
// import Principal "mo:base/Principal";
// import Buffer "mo:base/Buffer";
// import Array "mo:base/Array";
// import Types "types";
// module {

//     /////////////////
//     // Utilities ///
//     ///////////////

//     public func dateEqual(date1: Date, date2: Date) : Bool {
//         return date1.0 == date2.0 and date1.1 == date2.1 and date1.2 == date2.2;
//     };

//     public func dateHash(date: Date) : Hash.Hash {
//         return Int.hash(date.0 * 100 + date.1 * 10 + date.2);
//     };

//     /////////////
//     // TYPES ///
//     ///////////

//     public type Leaderboard = Types.Leaderboard;
//     public type UpgradeData = Types.UpgradeData;
//     public type StyleScore = Types.StyleScore;
//     public type EngagementScore = Types.EngagementScore;
//     public type MissionScore = Types.MissionScore;
//     public type TotalScore = Types.TotalScore;

//     type Date = Types.Date; //(Year, Month, Day)
//     type Time = Time.Time;
//     type TokenIdentifier = Text;
//     type Name = Text;
//     type Message = Text;

//     public class Factory (dependencies : Types.Dependencies) {


//         /* We keep a screenshot of the scores and the leaderboard everyday */
//         let _leaderboards : TrieMap.TrieMap<Date,Leaderboard> = TrieMap.TrieMap<Date,Leaderboard>(dateEqual, dateHash);
        
//         let style_score_daily : TrieMap.TrieMap<Date, [(TokenIdentifier, StyleScore)]> = TrieMap.TrieMap<Date, [(TokenIdentifier, StyleScore)]>(dateEqual, dateHash);
//         let engagement_score_daily : TrieMap.TrieMap<Date, [(Principal, EngagementScore)]> = TrieMap.TrieMap<Date, [(TokenIdentifier, EngagementScore)]>(dateEqual, dateHash);
//         let mission_score_daily : TrieMap.TrieMap<Date, [(Principal, MissionScore)]> = TrieMap.TrieMap<Date, [(TokenIdentifier, MissionScore)]>(dateEqual, dateHash);

//         let AVATAR_ACTOR = actor(Principal.toText(dependencies.cid_avatar)) : actor {
//             get_style_score : shared () -> async [(TokenIdentifier, StyleScore)];
//             get_infos_leaderboard : shared () -> async [(Principal, ?Name, ?, ?TokenIdentifier)];
//         };

//         // let _Missions = dependencies._Missions;
//         // let _Engagement = dependencies._Engagement;

//         public func preupgrade(ud : ?UpgradeData) : () {
//             switch(ud){
//                 case(null){};
//                 case(? ud){
//                     for((date, board) in ud.leaderboards.vals()){
//                         _leaderboards.put(date, board);
//                     };
//                 };
//             };
//         };

//         public func postupgrade() : UpgradeData {
//             return {
//                 leaderboards = Iter.toArray(_leaderboards.entries());
//             }
//         };

//         public func updateLeaderboard() : async () {
//             let infos = await AVATAR_ACTOR.get_infos_leaderboard();
//             let styles = await AVATAR_ACTOR.get_style_score();
//             // let mission = _Missions.get_mission_score();
//             // let engagement = _Engagement.get_engagement_score();
//             var buffer : Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, ?MissionScore, TotalScore)> = Buffer.Buffer<(Principal, ?Name, ?TokenIdentifier, ?StyleScore, ?EngagementScore, ?MissionScore, TotalScore)>(0);
//             for((p, name, message, tokenid) in infos.vals()){
//                 let style_score : ?StyleScore = switch(tokenid){
//                     case(null) {null};
//                     case(? tokenid) {
//                         switch(Array.find<(TokenIdentifier, StyleScore)>(styles, func (x) {x.0 == tokenid})){
//                             case(null) {null};
//                             case(? (token, score)){?score};
//                         };
//                     };
//                 };
//                 // Todo: Find mission score
//                 // Todo: Find engagement score
//                 buffer.add((p, name, tokenid, style_score, null, null, _getTotalScore(style_score, null, null)));
//             };
//             switch(Date.Date.nowToDatePartsISO8601()){
//                 case(null) assert(false);
//                 case(? date){
//                     _leaderboards.put(date, buffer.toArray());
//                 }
//             };
//         };


//         public func getCurrentLeaderboard() : ?Leaderboard {
//             let current_date = switch(Date.Date.nowToDatePartsISO8601()){
//                 case(null) return null;
//                 case(? date) getLeaderboard(date);
//             }
//         };

//         public func getLeaderboard(date : Date) : ?Leaderboard {
//             switch(_leaderboards.get(date)){
//                 case(null){
//                     return null;
//                 };
//                 case(? board){
//                     return ?board;
//                 };
//             };
//         };


//         /////////////////
//         // UTILITIES ///
//         ////////////////

//         func _getTotalScore(style : ?StyleScore, engage : ?EngagementScore, mission : ?MissionScore) : Nat {
//             var total = 0;
//             switch(style) {
//                 case(null) {};
//                 case(? value) {
//                     total := total + value;
//                 };
//             };
//             switch(engage){
//                 case(null) {};
//                 case(? engage) {
//                     // total := total + value;
//                 };
//             };
//             switch(mission){
//                 case(null) {};
//                 case(? mission) {
//                     // total := total + value;
//                 };
//             };
//             total;   
//         };




//     };
// }