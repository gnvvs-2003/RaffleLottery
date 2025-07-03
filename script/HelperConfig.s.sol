// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {CodeConstants} from "./CodeConstants.s.sol";

contract HelperConfig is Script, CodeConstants {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }
    NetworkConfig public localNetworkConfig;

    // network configs for chains mapping chainId to network Config
    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    /**
     * @dev : getting config by chainId
     */
    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        // if network config has chain id configs
        if (networkConfig[chainId].vrfCoordinator != address(0)) {
            return networkConfig[chainId];
        }
        // for local chain
        else if (networkConfig[chainId] == LOCAL_CHAIN_ID) {
            // return getOrCreateAnvilEthConfig();
        }
        // for sepolia config
        else {
            // return getSepoliaEthConfig();
        }
    }

    /**
     * @dev : local network
    function getOrCreateAnvilEthConfig() public pure returns(NetworkConfig memory){
        // mocks 
    }
     */

    /**
     * @dev : sepolia network
    }
     */
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30, // 30 seconds
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                callbackGasLimit: 500000,
                subscriptionId: 0 // for temporary
            });
    }
}
