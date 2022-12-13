// contracts/IAllowedTokensFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

interface IAllowedTokensFilter {

    function allowedTokens(address _token) external view returns (bool);
    function assignAllowedToken(address _token, bool _allow) external;
    function assignAllowedTokens(address[] memory _tokens, bool[] memory _allows) external;
    
}
