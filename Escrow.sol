pragma solidity ^0.4.22;

contract Escrow {
    //creator of contract and sender of funds
    address sender;
    //receiver of funds, party that must finish terms
    address receiver;
    //third party that determines when terms have been met
    address agent;
    //time after which sender can void the contract
    uint expirationTime;
    
    constructor(address _receiver, address _agent, uint timeBeforeExpiration) public payable {
        receiver = _receiver;
        agent = _agent;
        sender = msg.sender;
        expirationTime = now + timeBeforeExpiration;
    }
    
    function voidContract() public {
        //contract creator must be caller of function
        require(msg.sender == sender);
        //contract must have expired
        require(now > expirationTime);
        //destroy contract and send funds to sender
        selfdestruct(sender);
    }
    
    function confirmCompletion() public {
        //only agent can confirm that terms have been completed
        require(msg.sender == agent);
        //destroy contract and send funds to receiver
        selfdestruct(receiver);
    }
    
    function balance() public view returns(uint){
       return address(this).balance;
    }
}
