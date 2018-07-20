// Version of Solidity compiler this program was written for
pragma solidity ^0.4.11;

// Our first contract is a faucet!
contract Lottery {
    struct Contestant {
        address contestant;
        uint bet_amount;
        uint rand_val;
    }
    
    struct Contest {
        uint num_contestants;
        uint jackpot;    // Current state of the lottery
        uint lottery_end;
        bool ended;    // Set to true at the end, disallows any change.
        mapping (uint => Contestant) contestants;
    }
    
    // Events that will be fired on changes
    event jackpot_increased(uint jackpot);
    event lottery_ended(address winner, uint jackpot);

    uint num_lotteries;
    mapping (uint => Contest) contests;
    
    function new_lottery() public returns (uint lottery_id) {
        lottery_id = num_lotteries++; // lottery_id is return variable
        uint betting_time = 360;
        // Creates new struct and saves in storage. We leave out the mapping type and array.
        contests[lottery_id] = Contest(0, 0, now + betting_time, false);
    }
    
    // msg.value contains the bet amount
    function bet(uint lottery_id, uint rand_val) public payable{
        require(msg.value >= 0.001 ether);
        // require the bet amount is divisible by 0.001 ether else remainder discarded
        require(
            now <= contests[num_lotteries-1].lottery_end,
            "lottery is over"
        );
        // rand val between 2^10 and 2^32
        require(rand_val >= 1024 && rand_val <= 4294967296);
        
        Contest storage c = contests[lottery_id];
        c.contestants[c.num_contestants] = Contestant({
                contestant: msg.sender, 
                bet_amount: msg.value,
                rand_val: rand_val 
            });
        c.jackpot += msg.value;
        c.num_contestants++;
        emit jackpot_increased(c.jackpot);
    }
    
    function select_winner(uint lottery_id) public {
        Contest storage c = contests[lottery_id];
        uint val_to_hash;
        for (uint8 i = 0; i < c.num_contestants; i++) {
            val_to_hash += c.contestants[i].rand_val;
        }
        uint8 progress = 0;
        uint8 win_post = random(val_to_hash); // first contenstant to surpass post wins
        for (uint8 j = 0; j < c.num_contestants; j++) {
            progress += uint8(c.contestants[i].bet_amount);
            if (progress > win_post) {
                //address winner = c.contestants[i].contestant;
                c.contestants[i].contestant.transfer(c.jackpot);
                break;
            }
        }
    }
    
    // need to send hash value not random number...
    function random(uint val_to_hash) private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(val_to_hash)))%251);
    }
}
