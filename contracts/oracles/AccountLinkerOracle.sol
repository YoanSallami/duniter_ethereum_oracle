pragma solidity ^0.4.19;

/**
* @title The Duniter/Ethereum account linker
* @dev Query securely the Duniter blockchain in order to link the pubKey to an ethereum addresse
*      To link your Duniter account to an ethereum account you need to follow these steps :
*       0. Create an Ethereum and a Duniter account 
*       1. Send a transation with your Duniter account with your ethereum addresse in the comment section (you can use cesium at : "https://g1.duniter.fr/#/app/home")
*       2. Wait the transaction to be confirmed (you can check the http api at : "https://g1.duniter.fr/tx/history/[pubKey]"")
*       3. Get the number of the transaction() in your history (you can verify http://app.oraclize.it/home/test_query with json(https://g1.duniter.fr/tx/history/[pubKey].sent.[txNb].comment")
*       4. If the correct Ethereum addresse is displayed by the oraclize test query, then your setup is correct ! Enjoy !
*       5. Then call the linkAccounts method from your Ethereum address to link it with the Duniter pubKey
*/

import "../lib/oraclizeAPI.sol";

contract AccountLinkerOracle is usingOraclize {

    string public pubKey;

    uint256 linkingFee = 10 wei;

    mapping(address => string) etherumAddrToDuniterPubKey;

    mapping(bytes32 => bool) public requestPending;
    mapping(bytes32 => string) public requestIndexToPubKey;
    mapping(bytes32 => address) public requestIndexToSender;
    
    event LogNewOraclizeQuery(string description);
    event UpdatedMembership(string membership);

    function AccountLinkerOracle() public {
        // Set oraclize proof
        oraclize_setProof(proofType_TLSNotary);
    }

    function __callback(bytes32 myid, string result, bytes proof) public {
        // Check if the answer come from oraclize
        require(msg.sender == oraclize_cbAddress());
        // Check if the myid is valid
        require(requestPending[myid]);
        // Store the result from oraclize
        address addrProof = parseAddr(result);
        // Verify that the request sender match the address from oraclize
        require(requestIndexToSender[myid] == addr);
        // Store 
        etherumAddrToDuniterPubKey[addrProof] = requestIndexToPubKey[myid];
        // Emit event
        UpdatedMembership(membership);
        // Reset the request information
        delete requestPending[myid];
        delete requestIndexToPubKey[myid];
        delete requestIndexToSender[myid];
    }

    function linkAccounts(uint256 _txNb, string _pubKey) public payable {
        request(msg.value > oraclize_getPrice("URL") + linkingFee);
        bytes32 myid = oraclize_query("URL", strConcat("json(https://g1.duniter.fr/tx/history/", _pubKey, "/).sent.", uint2str(_txNb), ".comment");
        LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        requestPending[myid] = true;
        requestIndexToPubKey[myid] = _pubKey;
        requestIndexToSender[myid] = msg.sender;
    }
}