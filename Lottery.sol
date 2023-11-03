// SPDX-License-Identifier: MIT
///@title a lottery system
pragma solidity ^0.8.7;

import "./VRFv2Consumer.sol";

contract LotterySystem is VRFv2Consumer(6325) {

    struct Player {
        uint ID;
        address Address ;   
        uint256 balance;
        uint8 lotterywons; 
    }

    struct Lottery {
        uint ID;
        address winner;
        address[] participants;
    }

    mapping(address => uint) addressToID;      // Mapping from address to player's ID
    mapping(address => bool ) alreadySigendUp;  // Mapping to track if an address has signed up
    
    address lastLotteryWinner;                   // Address of the last lottery winner
    Player[] public players;                     // Array to store player information
    Lottery[] public lotteries;                  // Array to store lottery information

    constructor(){
        lotteries.push(Lottery(0,address(0),new address[](0))); // Initialize the first lottery
    }

    function _lotteryConducting() private returns(address)
    {
        requestRandomWords(); 
        // Determine the winner of the lottery
        lastLotteryWinner = lotteries[lotteries.length-1].participants[lastRequestId % 5];
        players[addressToID[lastLotteryWinner]].lotterywons++ ;
        players[addressToID[lastLotteryWinner]].balance += 5 * 10 ** 9 wei;
        return (lastLotteryWinner);
    }
    
    function signUp() external {
        require(alreadySigendUp[msg.sender] == false);
        // Register a new player
        players.push(Player(players.length, msg.sender, 0, 0));
        addressToID[msg.sender] = players.length - 1;
        alreadySigendUp[msg.sender] = true;
    }

    function deposit() external payable {
        require(alreadySigendUp[msg.sender] == true);
        require(msg.value >= 10 ** 9 wei);
        // Deposit funds into a player's balance
        players[addressToID[msg.sender]].balance += msg.value;
    }

    function join() external {
        require(alreadySigendUp[msg.sender] == true);
        require(players[addressToID[msg.sender]].balance >= 10 ** 9 wei);
        // Allow a player to join the current lottery
        players[addressToID[msg.sender]].balance -= 10 ** 9 wei;
        lotteries[lotteries.length - 1].participants.push(msg.sender);
        if (lotteries[lotteries.length - 1].participants.length == 5)
        {
            // If the maximum number of participants is reached, conduct a new lottery
            lotteries[lotteries.length - 1].winner = _lotteryConducting();
            lotteries.push(Lottery(lotteries.length, address(0), new address[](0)));
        }
    }
    
    function withdraw(uint _amount) external {
        require(players[addressToID[msg.sender]].Address == msg.sender);
        require(players[addressToID[msg.sender]].balance >= _amount);
        require(_amount >= 10**6 wei);
        // Withdraw funds from a player's balance
        players[addressToID[msg.sender]].balance -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}
