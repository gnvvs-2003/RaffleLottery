// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {Raffle} from "../src/Raffle.sol";

import {DeployRaffle} from "../script/DeployRaffle.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {CodeConstants} from "../script/CodeConstants.s.sol";

contract RaffleTest is Test, CodeConstants {
    Raffle public raffle;
    HelperConfig public helperConfig;

    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed player);

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    // mocking player
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        /**
         * @dev : For testing Raffle we need to deploy the Raffle
         */
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployContract();
        // adding some funds to `PLAYER`
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
    }

    // @note : Tests

    /**
     * @dev : Steps for testing
     * 1. Arrange
     * 2. Act
     * 3. Asset
     */

    // Test-1 : get raffle state at the start
    function test__RaffleInitialStateIsOpen() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    // Test-2 : player can only enter if paid enough
    function test__RaffleRevertIfPlayerDonotPayEnough() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__sendMoneyToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    // Test-3 : player enter raffle
    function test__RaffleRecordsPlayersWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    /**
     * @dev : Tests for events
     */

    // Test-4 : Test the player who entered raffle
    function test__EnteringRaffleEmitEvent() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEnter(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    /**
     * @dev : For time based events or functions tensting
     */
    // Test-5 : Test for players to not enter raffle while raffle state is calculating
    function test__DontAllowPlayersToEnterRaffleWhileRaffleStateIsCalculating()
        public
    {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep(""); // This changes the raffle state to CALCULATING
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
}
