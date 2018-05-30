pragma solidity ^0.4.19;

/**
* @title The Duniter membership tracker
* @dev Enable to query securely the Duniter blockchain in order to track the memberships of the given pubKey
**/

import "../lib/oraclizeAPI.sol";

contract MembershipTrackerOracle is usingOraclize {

    string public pubKey;
    string public membership;

    mapping(bytes32 => bool) public requestPending;
    
    event LogNewOraclizeQuery(string description);
    event UpdatedMembership(string membership);

    function DuniterMembershipTrackerOracle(string _pubKey) public {
        // Store the pubKey
        pubKey = _pubKey;
        // Set oraclize proof
        oraclize_setProof(proofType_TLSNotary);
        // Get the actual membership
        _update(0);
    }

    function __callback(bytes32 myid, string result, bytes proof) public {
        // Check if the answer come from oraclize
        require(msg.sender == oraclize_cbAddress());
        // Check if the myid is valid
        require(requestPending[myid]);
        // Store the result from oraclize
        membership = result;
        // Emit event
        UpdatedMembership(membership);
        // Reset the request information
        delete requestPending[myid];
        // Query for tracking
        _update(2*month);
    }

    function _update(uint256 delay) private {
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            bytes32 myid = oraclize_query(delay, "URL", strConcat("https://g1.duniter.fr/blockchain/memberships/", pubKey, "/"));
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            requestPending[myid] = true;
        }
    }
}