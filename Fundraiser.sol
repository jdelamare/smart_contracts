pragma solidity ^0.4.22;

contract Fundraiser {
    address owner;
    //target fundraising value
    uint target;
    //time that fundraiser ends
    uint endTime;
    //list of contributors
    Contributor[] contributors;
    
    struct Contributor{
        address userAddress;
        uint contribution;
    }
    
    constructor(uint _target, uint duration) public payable {
        owner = msg.sender;
        target = _target;
        endTime = now + duration;
    }
    
    function contribute() public payable {
        //require that fundraiser hasn't ended yet
        require(now < endTime);
        //add to list of contributors
        contributors.push(Contributor(msg.sender,msg.value));
    }
    
    function refund() public{
        //allow refunds once time has ended if goal hasn't been met
        require(now > endTime);
        require(address(this).balance < target);
        //refund all contributors
        for(uint i; i<contributors.length;i++) {
            contributors[i].userAddress.transfer(contributors[i].contribution);
        }
    }
    
    function collect() public{
        //once target has been reached, owner can collect funds
        require(address(this).balance >= target);
        require(msg.sender == owner);
        selfdestruct(owner);
    }
    
}
