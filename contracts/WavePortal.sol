// SPDX-License-Identifier: UNLICENSED

pragma solidity^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /*
    * We will be using below to help generate a random number
    */
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

// A struct is basically a custom datatype where we can customize what we want to hold inside it.
    struct Wave {
      address waver; // The address of the user who waved
      string message; // The message the user sent.
      uint256 timestamp; 
    }

    /*
    * I declare a variable waves that lets me store an array of structs.
    * This is what lets me hold all the waves anyone ever sends to me!
    */

    Wave[] waves;

    /*
    * This is an address => uint mapping, meaning I can associate an address with a number!
    * In this case, I'll be storing the address with the last time the user waved at us.
    */
    mapping(address => uint256) public lastWaveAt;

    constructor() payable {
      console.log("We have been constructed!");

      /*
      * Set the initial seed
      */
      seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
      /*
      * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored 
      */
      require(
        lastWaveAt[msg.sender] + 30 seconds < block.timestamp,
        "Must wait 30 seconds before waving again."
      );

      /*
      * Update the current timestamp we have for the user
      */
      lastWaveAt[msg.sender] = block.timestamp;

      totalWaves += 1;
      console.log("%s has waved!", msg.sender);

      waves.push(Wave(msg.sender, _message, block.timestamp));

      /*
      * Generate a new seed for the next user that send a wave 
      */
      seed = (block.difficulty + block.timestamp + seed) % 100;

      console.log("Random # generated: %d", seed);

      /*
      * Give a 50% chance that the user wins the prize. 
      */

      if (seed <= 50) {
        console.log("%s won!", msg.sender);

        uint256 prizeAmount = 0.0001 ether;
        require(
          prizeAmount <= address(this).balance,
          "Trying to withdraw more money than the contract has."
        );
        (bool success,) = (msg.sender).call{value: prizeAmount}("");
        require(success, "Failed to withdraw money from contract.");
      }

      emit NewWave(msg.sender, block.timestamp, _message);

    }

    function getAllWaves() public view returns (Wave[] memory) {
      return waves;
    }

    function getTotalWaves() public view returns (uint256) {
      console.log("We have %d total waves!", totalWaves);
      return totalWaves;
    }
}