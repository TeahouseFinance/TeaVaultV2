// contracts/RBNMinterFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters for Ribbon's RBN token minter contract
/// @author Teahouse Finance
contract RBNMinterFilter is BaseFilter {

    // no specific restrictions
    function mint(address /*gauge_addr*/) external pure returns (bytes4) {
        return  MAGICVALUE;
    }

    // no specific restrictions
    function mint_many(address[8] memory /*gauge_addrs*/) external pure returns (bytes4) {
        return  MAGICVALUE;
    }

    // requires _for to be msg.sender
    function mint_for(address /*gauge_addr*/, address _for) external view returns (bytes4) {
        if (_for != msg.sender) {
            revert("Outside address not allowed");
        }

        return MAGICVALUE;
    }
}