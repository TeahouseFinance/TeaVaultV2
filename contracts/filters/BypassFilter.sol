// contracts/BypassFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

/// @title Bypass filter
/// @author Teahouse Finance
contract BypassFilter {

    /// @notice A filter function must returns MAGICVALUE to indicate a whitelisted operation
    /// @notice otherwise, it should revert
    /// @notice MAGICVALUE is from bytes4(keccak256("TeaVaultV2"))
    bytes4 constant internal MAGICVALUE = 0x59faaa03;

    fallback() external {
        uint256 returnValue = uint256(uint32(MAGICVALUE)) << 224;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, returnValue)
            return(ptr, 0x20)
        }
    }
}