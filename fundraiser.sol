// Version of Solidity compiler this program was written for
pragma solidity ^0.4.22;

// Our first contract is a faucet!
contract Fundraiser {
    address company;
    uint expiration_time;
    struct Contributor{
        address addr;
        uint contribution;
    }
    Contributor[] contributor_list;
    constructor(
        uint timespan,
        address company
    ) public payable {
        expiration_time = now + timespan;
        company = company;
    }
    
    function give_funds() public payable {
        require(msg.value >= 0.01 ether);
        require(expiration_time > now);
        contributor_list.push(Contributor(msg.sender, msg.value));
    }
    
    function disperse() public {
        require(expiration_time > now);
        if(address(this).balance >= 1 ether) {
            selfdestruct(company);
        }
        else {
            for(uint i = 0; i < contributor_list.length; i++) {
                contributor_list[i].addr.transfer(contributor_list[i].contribution);
            }
        }
    }
}
