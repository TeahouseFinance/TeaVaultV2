// contracts/LiquidityGaugeFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../ERC20Filter.sol";

/// @title A simple implementation of filters for Ribbon's liquidity gauge contract
/// @author Teahouse Finance
contract LiquidityGaugeFilter is ERC20Filter {

    // requires addr to be msg.sender
    function user_checkpoint(address addr) external view returns (bytes4) {
        if (addr != msg.sender) {
            revert("Outside address not allowed");
        }

        return MAGICVALUE;
    }

    // no specific restrictions
    function withdraw(uint256 /*_value*/) external pure returns (bytes4) {
        return  MAGICVALUE;
    }

    // no specific restrictions
    function deposit(uint256 /*_value*/) external pure returns (bytes4) {
        return  MAGICVALUE;
    }

    // no specific restrictions
    function claim_rewards() external pure returns (bytes4) {
        return  MAGICVALUE;
    }
}