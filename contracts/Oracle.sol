/*


.*/

pragma solidity ^0.4.19;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Oracle is Ownable {
    
    event NewRequest(uint256 requestId);
    
    struct Request {
        bytes data;
        function(bytes memory) external callback;
    }
    
    Request[] public requests;
    uint256 requestCount;

    function Oracle() public {
        owner = msg.sender;
    }

    function query(bytes data, function(bytes memory) external callback) public returns(uint256) {
        uint256 newRequestId = requests.push(Request(data, callback));
        requestCount+=1;
        emit NewRequest(newRequestId);
        return newRequestId;
    }
    
    function reply(uint256 id, bytes response, bytes proof) public {
        require(_checkReply(response, proof));
        requests[requestId].callback(response);
    }
    
    function _checkReply(bytes response, bytes proof) private pure returns (bool succes) {
        //TODO
        return true;
    }
}