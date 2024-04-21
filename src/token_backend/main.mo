import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

actor {
  var owner: Principal = Principal.fromText("ngxwj-4x4sh-bzgkq-zyluv-tdllf-6dbla-bnwsv-hznzq-24ccp-w45mj-kqe");
  var totalSupply = 1000000000;
  var symbol = "REED";

  private stable var balanceEntries: [(Principal, Nat)] = [];
  private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
  if (balances.size() < 1) {
    balances.put(owner, totalSupply);
  };

  public query func balanceOf(who: Principal): async Nat {
    let balance: Nat = switch (balances.get(who)) {
      case null 0;
      case (?result) result;
    };

    return balance;
  };

  public query func getSymbol(): async Text {
    return symbol;
  };

  public shared(msg) func payout(): async Text {
    Debug.print(debug_show(msg.caller));
    if (balances.get(msg.caller) == null) {
      let amount: Nat = 10000;
      let result = await transfer(msg.caller, amount);
      return result;
    } else {
      return "Alredy claimed";
    };
  };

  public shared(msg) func transfer(to: Principal, amount: Nat): async Text {
    let ownerBalance = await balanceOf(msg.caller);

    if (ownerBalance > amount) {
      let newOwnerBalance: Nat = ownerBalance - amount;
      balances.put(msg.caller, newOwnerBalance);

      let toBalance = await balanceOf(to);
      let newToBalance = toBalance + amount;
      balances.put(to, newToBalance);
      
      return "Success";
    } else {
      return "Insufficient Fund";
    }

  };

  system func preupgrade() {
    balanceEntries := Iter.toArray(balances.entries());
  };

  system func postupgrade() {
    let iter = balanceEntries.vals();
    balances := HashMap.fromIter<Principal, Nat>(iter, 1, Principal.equal, Principal.hash);
    if (balances.size() < 1) {
      balances.put(owner, totalSupply);
    };
  };
};
