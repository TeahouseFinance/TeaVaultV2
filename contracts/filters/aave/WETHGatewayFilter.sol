// contracts/WETHGatewayFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../BaseFilter.sol";

/// @title A simple implementation of filters for AAVE WETH Gateway contract
/// @author Teahouse Finance
contract WETHGatewayFilter is BaseFilter, Ownable {

    // allowed lending pool address
    address allowedLendingPool;

    // assign allowedLendingPool
    function setLendingPool(address _lendingPool) external onlyOwner {
        allowedLendingPool = _lendingPool;
    }

    // requires lendingPool to be allowedLendingPool
    function borrowETH(address lendingPool, uint256 /*amount*/, uint256 /*interesRateMode*/, uint16 /*referralCode*/) external view returns (bytes4) {
        if (lendingPool != allowedLendingPool) {
            revert("Lending pool not allowed");
        }

        return MAGICVALUE;
    }

    // requires lendingPool to be allowedLendingPool
    // requires onBehalfOf to be msg.sender
    function depositETH(address lendingPool, address onBehalfOf, uint16 /*referralCode*/) external view returns (bytes4) {
        if (lendingPool != allowedLendingPool) {
            revert("Lending pool not allowed");
        }


        if (onBehalfOf != msg.sender) {
            revert("outside onBehalfOf not allowed");
        }

        return MAGICVALUE;
    }

    // requires lendingPool to be allowedLendingPool
    // requires onBehalfOf to be msg.sender
    function repayETH(address lendingPool, uint256 /*amount*/, uint256 /*rateMode*/, address onBehalfOf) external view returns (bytes4) {
        if (lendingPool != allowedLendingPool) {
            revert("Lending pool not allowed");
        }


        if (onBehalfOf != msg.sender) {
            revert("outside onBehalfOf not allowed");
        }

        return MAGICVALUE;
    }

    // requires lendingPool to be allowedLendingPool
    // requires to to be msg.sender
    function withdrawETH(address lendingPool, uint256 /*amount*/, address to) external view returns (bytes4) {
        if (lendingPool != allowedLendingPool) {
            revert("Lending pool not allowed");
        }


        if (to != msg.sender) {
            revert("outside to not allowed");
        }

        return MAGICVALUE;
    }
}