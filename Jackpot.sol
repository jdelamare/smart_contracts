pragma solidity ^0.4.22;

contract Jackpot {
    //time when bidding period ends
    uint public bidPeriodEnd;
    //time when seed confirmation period ends
    uint public confirmationPeriodEnd;
    //flag set to true when winner has been determined and payed
    bool ended;
    
    //record of value each address has bid
    mapping(address => uint) bids;
    //total value in jackpot
    uint amount;
    //hashes of seeds from each user
    mapping(address => bytes32) hashes;
    //sum of all confirmed seeds
    uint seedSum;
    //list of bidders that have confirmed their seeds
    address[] confirmedBidders;
    //value of confirmed bids; used for winner selection
    uint confirmedAmount;
    
    event JackpotIncreased(uint amount);
    event WinnerAnnounced(address winner, uint amount, uint256 bid);

    /// Create a simple Jackpot with `biddingTime`
    /// seconds bidding time
    constructor(
        uint biddingTime,
        uint confirmationTime
    ) public payable {
        bidPeriodEnd = now + biddingTime;
        confirmationPeriodEnd = bidPeriodEnd + confirmationTime;
    }
    
    function enter(bytes32 hash) public payable {
        //require that the bidding period has not ended
        require(now < bidPeriodEnd);
        //minimum value bid must be reached
        require(msg.value > .01 ether);
        //sender must not have already bid
        require(bids[msg.sender]==0);
        
        bids[msg.sender] = msg.value;
        hashes[msg.sender] = hash;
        amount += msg.value;
        emit JackpotIncreased(amount);
    }
    
    function confirmSeed(uint seed) public {
        //confirmation period must be active
        require(now >= bidPeriodEnd);
        require(now < confirmationPeriodEnd);
        //seeds must be above 100 (security feauture; threshold is low for testing)
        require(seed >= 100);
        //seed must match hash previously recieved by sender
        require(keccak256(abi.encodePacked(seed)) == hashes[msg.sender]);
        //left shift hash so sender cannot call this function again
        hashes[msg.sender] <<= 1;
        
        //sender is now confirmed
        confirmedBidders.push(msg.sender);
        seedSum += seed;
        confirmedAmount += bids[msg.sender];
    }
    
    function determineWinner() public {
        //confirmation period must be over
        require(now > confirmationPeriodEnd);
        //require winner hasn't already been payed
        require(!ended);
        
        ended = true;
        
        //generate hash and winning target from user-random seedSum
        bytes32 sumHash = keccak256(abi.encodePacked(seedSum));
        uint hashInt = uint(sumHash);
        uint target = hashInt % confirmedAmount;
        //tally of bids
        uint sumSearch = 0;
        for(uint i; i<confirmedBidders.length;i++) {
            //increase tally by each bid
            sumSearch += bids[confirmedBidders[i]];
            //winner is the first bid where tally goes above target
            if(sumSearch > target){
                address winner = confirmedBidders[i];
                winner.transfer(amount);
                emit WinnerAnnounced(winner,amount,bids[winner]);
                return;
            }
        }
    }
    
    //supplementary function for testing
    function currentTime() view public returns(uint){
        return now;
    }
    
    //supplementary function for testing
    function returnHash(uint input) pure public returns(bytes32){
        return keccak256(abi.encodePacked(input));
    }
}
