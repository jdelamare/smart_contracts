pragma solidity ^0.4.22;

contract TimedPiggyBank {
    //owner of piggybank
    address public owner;
    //time that funds can be withdrawn
    uint public endTime;
    
    constructor(uint duration) public {
        owner = msg.sender;
        endTime = now + duration;
    }
    
    //payable function that can be used to deposit funds
    function deposit() public payable {}
    
    function withdraw() public {
        //only owner can withdraw funds
        require(msg.sender == owner);
        //end time must be reached before funds can be withdrawn
        require(now > endTime);
        owner.transfer(address(this).balance);
    }
    
    function balance() public view returns(uint){
       return address(this).balance;
    }
}
