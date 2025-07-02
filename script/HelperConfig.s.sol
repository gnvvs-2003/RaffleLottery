// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
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
    function getConfigByChainId(uint256 chainId) public returns(NetworkConfig memory){

    }
     */

    /**
     * @dev : local network
    function getOrCreateAnvilEthConfig() public pure returns(NetworkConfig memory){
        // mocks 
    }
     */

    /**
     * @dev : sepolia network
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        return NetworkConfig(
            
        );
    }
     */
}
