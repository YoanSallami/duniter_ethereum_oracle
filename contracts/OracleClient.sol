/*


.*/

pragma solidity ^0.4.19;

import "./Oracle.sol"


contract OracleClient {

	event FilledRequest();

	Oracle constant public oracle = Oracle(0xca35b7d915458ef540ade6068dfe2f44e8fa733c);

	modifier onlyOracle(){
        require(msg.sender==address(oracle));
        _;
    }

    function query(bytes data) public {
        oracle.query(data, this.fill);
    }

    function fill(bytes response) public onlyOracle {
        emit FilledRequest();
    }

}