// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Raffle smart contract
 * @author gnvvs-2003
 * @notice Implementation of chainlink VRF2_5
 */

contract Raffle {
    // requirements to enter raffle (entrance fee,players,times,interval)
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;

    address[] private s_players;
    uint256 private s_lastTimeStamp;

    constructor(uint256 entranceFee, uint256 interval) {
        // entrance fee
        i_entranceFee = entranceFee;
        // duration of lottery
        i_interval = interval;
        // for time stamp of last deployed contract
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        /**
         * @dev : player conditions to enter raffle
         * @note : player should pay the entrance fee
         * @note : the raffle should be open
         */
        if (msg.value < i_entranceFee) {
            revert Raffle__sendMoneyToEnterRaffle();
        }
        // player enter raffle : add player
        s_players.push(payable(msg.sender));
    }

    function pickWinner() external view {
        /**
         * @note : Steps to pick winner after the interval of the raffle is completed
         * @note : pick a random number -> use random number to call the winner -> automate the pick winner function
         */
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            // interval yet to complete
            revert Raffle__notEnoughTimePassed();
        }
        // get random number
        // call the winner using random number
        // automate the program
    }

    // custom errors
    error Raffle__sendMoneyToEnterRaffle();
    error Raffle__notEnoughTimePassed();
}
