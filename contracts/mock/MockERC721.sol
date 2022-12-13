// contracts/MockERC721.sol
// SPDX-License-Identifier: MIT
// Teahouse Finance

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MockERC721 is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Mock ERC721", "MOCK") {
    }

    function mint(address _to) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(_to, newItemId);

        _tokenIds.increment();
        return newItemId;
    }
}
