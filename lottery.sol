// Version of Solidity compiler this program was written for
pragma solidity ^0.4.22;

// Our first contract is a faucet!
contract Lottery {
    struct Contestant {
        address addr;
        uint bet_amount;
        bool valid;
    }
    mapping (bytes32 => Contestant) hash_to_contestant;
    bytes32 [] hashes;
    uint lottery_end;       // in seconds
    uint confirmation_end;
    uint num_contestants;
    uint jackpot;
    
    // Events that will be fired on changes
    event jackpot_increased(uint jackpot);
    event lottery_ended(uint jackpot);
    event winner_chosen(address winner);
    
    constructor(
        uint betting_time,
        uint confirmation_time
    ) public payable {
        lottery_end = now + betting_time;
        confirmation_end = lottery_end + 60;
    }
     
    function bet(bytes32 hash) public payable {
        require(msg.value >= 0.001 ether);
        require(
            now <= lottery_end,
            "lottery is over"
        );
        // require that you can only bet once
        jackpot += msg.value;
        hash_to_contestant[hash].addr = msg.sender;
        hash_to_contestant[hash].bet_amount = msg.value;
        hash_to_contestant[hash].valid = false;
        hashes.push(hash);
        num_contestants++;
        emit jackpot_increased(jackpot);
    }
    
    function select_winner() public view returns (uint) {
        uint running_total;
        uint win_value;
        for (uint8 i = 0; i < num_contestants; i++) {
            win_value += uint(hashes[i]);
        }
        win_value = win_value % jackpot;

        for (uint8 j = 0; j < num_contestants; j++) {
            // for each hash grab that contestants bet amount
            running_total += hash_to_contestant[hashes[j]].bet_amount;
            if (running_total >= win_value) {
                // emit the winner has been chosen (address of winner)
                if (hash_to_contestant[hashes[j]].valid) {
                    Contestant winner = hash_to_contestant[hashes[j]];
                    emit winner_chosen(winner.addr);
                    winner.addr.transfer(jackpot);
                    return winner.bet_amount;
                }
                // else their plain text value is a lie, next possible winner
            }
        }
        return 1;
    }
    
    // once betting_time is up everybody sends in their number
    function confirm_number(uint revealed_number) public {
        if (hash_to_contestant[confirm_hash(revealed_number)].addr == msg.sender) {
            hash_to_contestant[confirm_hash(revealed_number)].valid = true;
        }
    }
    
    function confirm_hash(uint val_to_hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(val_to_hash));
    }
}
