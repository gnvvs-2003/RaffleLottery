// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.4.0/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

import {VRFV2PlusClient} from "@chainlink/contracts@1.4.0/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle smart contract
 * @author gnvvs-2003
 * @notice Implementation of chainlink VRF2_5
 */
contract Raffle is VRFConsumerBaseV2Plus {
    // requirements to enter raffle (entrance fee,players,times,interval)
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    bytes32 private immutable i_keyHash;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    uint16 private constant REQUEST_CONFIRMATIONS = 4;
    uint32 private constant NUM_WORDS = 1;

    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1
    }

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        // entrance fee
        i_entranceFee = entranceFee;
        // duration of lottery
        i_interval = interval;
        // for time stamp of last deployed contract
        s_lastTimeStamp = block.timestamp;
        // raffle state
        s_raffleState = RaffleState.OPEN;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    event WinnerPicked(address indexed winner);
    event RaffleEnter(address indexed player);
    event RequestRaffleWinner(uint256 indexed requestId);

    function enterRaffle() external payable {
        /**
         * @dev : player conditions to enter raffle
         * @note : player should pay the entrance fee
         * @note : the raffle should be open
         */
        if (msg.value < i_entranceFee) {
            revert Raffle__sendMoneyToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        // player enter raffle : add player
        s_players.push(payable(msg.sender));
        // emit the player who entered the raffle
        emit RaffleEnter(msg.sender);
    }

    /**
     * @dev : adding checkUpKeep() and performUpKeep() for chainlink automation
     */
    function checkUpkeep(
        bytes memory
    ) public view returns (bool upkeepNeeded, bytes memory) {
        /**
         * @dev : conditions for upkeep to return true is
         * 1. The time should pass the raffle time
         * 2. The lottery should be open
         * 3. The contract should have some balance
         * 4. The lottery should have players
         */
        bool timeHasPassed = ((block.timestamp) - s_lastTimeStamp) >=
            i_interval;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, "");
    }

    function performUpkeep(bytes calldata /* performData */) external {
        /**
         * @dev : if upKeepNeeded() returns true we need to implement this function else we need to revert
         */
        (bool upKeepNeeded, ) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        // pick winner
        pickWinner();
    }

    function pickWinner() public {
        /**
         * @note : Steps to pick winner after the interval of the raffle is completed
         * @note : pick a random number -> use random number to call the winner -> automate the pick winner function
         */
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            // interval yet to complete
            revert Raffle__notEnoughTimePassed();
        }
        // update the raffle state
        s_raffleState = RaffleState.CALCULATING;
        // get random number
        // call the winner using random number
        // automate the program

        /**
         * @dev : Adding the random number using chainlink contracts
         */
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                /**
                 * @dev : keyHash,subscriptionId,requestConfirmations,callbackGasLimit,numWords,nativePayment declared in top
                 */
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                ) // new parameter
            });
        uint256 requestID = s_vrfCoordinator.requestRandomWords(request);
        // emit the requestID
        emit RequestRaffleWinner(requestID);
    }

    // custom errors
    error Raffle__sendMoneyToEnterRaffle();
    error Raffle__notEnoughTimePassed();
    error Raffle__failedPaymentToWinnerError();
    error Raffle__RaffleNotOpen();
    error Raffle__UpKeepNotNeeded(
        uint256 balance,
        uint256 playersLength,
        uint256 raffleState
    );

    // interface functions
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        // pay the Raffle amount to winner
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__failedPaymentToWinnerError();
        }
        // emit the recent winner
        emit WinnerPicked(s_recentWinner);
    }

    // @note : Getters

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }
}
