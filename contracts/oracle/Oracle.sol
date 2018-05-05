/*


.*/

pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Oracle is Ownable {
    
    event NewRequest(uint256 requestId);
    event NewReply(uint256 requestId, bytes response);
    
    bytes public pubKey="";
    
    struct Request {
        bytes data;
        bytes response;
    }
    
    Request[] public requests;
    uint256 requestCount;

    modifier isInitialized() {
        require(pubKey!="");
    }
    
    function Oracle(bytes _pubKey) public {
        owner = msg.sender;
        pubKey = _pubKey;
    }
    
    function setPubKey(bytes _pubKey) public onlyOwner {
        require(pubKey=="");
        pubKey = _pubKey;
    }
    
    function query(bytes data) public 
    isInitialized returns(uint256) 
    {
        uint256 newRequestId = requests.push(Request(data, ""));
        requestCount+=1;
        emit NewRequest(newRequestId);
        return newRequestId;
    }
    
    function callback(uint256 id, bytes response, bytes proof) public 
        isInitialized 
    {
        require(checkReply(response, proof));
        requests[requestId].response = response;
        emit NewReply(requestId, response);
    }
    
    function checkReply(bytes response, proof) internal returns (bool succes){
        //TODO
        return true;
    }
}