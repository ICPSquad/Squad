import Types "types";
import List "mo:base/List";
module {

    public class Logs(state : Types.State) : Types.Interface {

        type Event = Types.Event;
        private var logs : List.List<Event> = List.fromArray<Event>(state.events);

        public func addLog(event : Event) : () {
            logs := List.push<Event>(event, logs);
            return;
        };

        public func getLogs() : List.List<Event> {
            return logs;
        };

        public func getStateStable() : [Event] {
            List.toArray<Event>(logs);
        };

        // Drop the last percent% of the list
        public func purgeLogs(percent : Types.Percent) : () {
            let size : Nat = List.size<Event>(logs);
            logs := List.take<Event>(logs, size - size / percent);
        };

    };

};