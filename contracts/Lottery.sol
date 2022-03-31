// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LotteryTicket.sol";

contract Lottery {
    LotteryTicket public ticket;
    uint256 public id;
    address public manager;
    address payable[] public players;
    uint8 public constant MAX_PLAYERS = 10;

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > 0 ether, "0 Ether is not valid");
        players.push(payable(msg.sender));
        ticket.safeMint(msg.sender, id);
        id++;
        
        if (players.length == MAX_PLAYERS) {
            pickWinner();
        }
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encode(block.difficulty, players, block.timestamp)
                )
            );
    }

    function pickWinner() public {
        uint256 index = random() % players.length;
        players[index].transfer(address(this).balance);
        players = new address payable[](0);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
