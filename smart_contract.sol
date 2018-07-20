// Version of Solidity compiler this program was written for
pragma solidity ^0.4.19;

// Our first contract is a faucet!
contract Lottery {
    uint public lottery_end;
    address[] potential_winners;
    
    // Current state of the lottery
    uint public jackpot;
    
    // Set to true at the end, disallows any change.
    bool ended;
    
    // Events that will be fired on changes
    event jackpot_increased(uint jackpot);
    event lottery_ended(address winner, uint jackpot);
    
    /// Create a simple auction with `_bettingTime`
    /// seconds betting time on behalf of the
    /// beneficiary address `_beneficiary`.
    constructor(
        uint _bettingTime
    ) public {
        lottery_end = now + _bettingTime;
    }
    
    function bet(uint bet_amount) public payable{
        require(bet_amount >= 100000000000000000);
        require(
            now <= lottery_end,
            "lottery is over"
        );
        potential_winners.push(msg.sender);
        jackpot = msg.value;
        emit jackpot_increased(jackpot);
    }
    
    function select_winner(address) public {
        uint x = 2;
        potential_winners[x].transfer(jackpot);
    }

	// Give out ether to anyone who asks
// 	function withdraw(uint withdraw_amount) public {

//     	// Limit withdrawal amount
//     	require(withdraw_amount <= 100000000000000000);

//     	// Send the amount to the address that requested it
//     	msg.sender.transfer(withdraw_amount);
//     }
    
	// Accept any incoming amount
	// function () public payable {}

}
