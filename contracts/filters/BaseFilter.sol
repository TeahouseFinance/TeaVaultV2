// contracts/BaseFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;


/// @title A basic filter
/// @author Teahouse Finance
contract BaseFilter {

    /// @notice A filter function must returns MAGICVALUE to indicate a whitelisted operation
    /// @notice otherwise, it should revert
    /// @notice MAGICVALUE is from bytes4(keccak256("TeaVaultV2"))
    bytes4 constant internal MAGICVALUE = 0x59faaa03;

    fallback() external {
        revert("Function is not whitelisted");
    }
}
