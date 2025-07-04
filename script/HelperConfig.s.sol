// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {CodeConstants} from "./CodeConstants.s.sol";

import {LinkToken} from "../test/mocks/LinkToken.t.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts@1.4.0/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract HelperConfig is Script, CodeConstants {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address link;
    }

    NetworkConfig public localNetworkConfig;

    // network configs for chains mapping chainId to network Config
    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    constructor() {
        networkConfig[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    /**
     * @dev : getting config by chainId
     */
    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    /**
     * @dev : local chain config
     */
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        // if network config has chain id configs
        if (networkConfig[chainId].vrfCoordinator != address(0)) {
            return networkConfig[chainId];
        }
        // for local chain
        else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        }
        // for sepolia config
        else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /**
     * @dev : local network
     */
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // if a local chain already exists
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }
        // if no local network was found use mocking
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
        LinkToken link = new LinkToken();
        uint256 subscriptionId = vrfCoordinator.createSubscription();
        vm.stopBroadcast();
        /**
         * @dev : creating a new local network
         */
        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinator),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 500000,
            subscriptionId: subscriptionId,
            link: address(link)
        });

        return localNetworkConfig;
    }

    /**
     * @dev : sepolia network
     * }
     */
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30, // 30 seconds
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 0, // for temporary
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    error HelperConfig__InvalidChainId();
}
