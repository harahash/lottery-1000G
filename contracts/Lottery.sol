// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Lottery is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable public manager;
    address payable[] public players;
    uint8 public constant MAX_PLAYERS = 10;

    uint256 public _startTime;
    uint256 public _endTime;

    constructor() ERC721("Lottery", "LTR") {
        manager = payable(msg.sender);
    }

    function startLottery() public {
        _startTime = block.timestamp;
    }

    function endLottery() public {
        _endTime = _startTime + 10 minutes;
    }

    function getTimeLeft() public view returns (uint256) {
        return _endTime - block.timestamp;
    }

    function enter() public payable {
        require(block.timestamp <= _endTime);
        if (players.length == 0) {
            startLottery();
        }

        require(msg.value > 0 ether, "0 Ether is not valid");
        players.push(payable(msg.sender));

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _tokenIds.increment();

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

        uint256 ownerFee = (address(this).balance * 9) / 10;
        manager.transfer(ownerFee);
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
