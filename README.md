# TeaVaultV2

TeaVaultV2 is a wallet designed to allow a manager (separate from the wallet owner or investor) to perform some predefined tasks.

It uses a filter system which let the owner to assign which contracts, which functions, and which parameters may be called by the manager. This allows the owner and investor to limit the manager to perform operations on fund management, but not to take the fund to other wallet addresses.

## Introduction

There are three roles in TeaVaultV2. Each role can be assigned to only one address.

* Owner: administrator with full access
* Investor: can deposit to and withdraw funds from the vault
* Manager: can perform operations allowed by the filter system

### Filter System

The filter system is based on separate smart contracts. Basically, when a manager made a transaction, TeaVaultV2 queries the FilterMapper contract to get the corresponding filter smart contract for the target address. If a filter does not exist for the target address, the transaction is declined. Then, TeaVaultV2 calls the filter contract with the transaction data to check if the function called is allowed. TeaVaultV2 only make the transaction if the filter allows the function to be called.

#### Filter Smart Contract

A filter smart contract should contain the same functions allowed for the target smart contract and returns a magic value if the call should be allowed, and revert if the call should be decline. The magic value is 0x59faaa03 (which is from `bytes4(keccak256("TeaVaultV2"))`).

The BaseFilter contract can be used to simplify the filter smart contract a bit. An example for a hypothetical DeFi:

```solidity
contract MyFilter is BaseFilter {

    function deposit(uint256 _amount) external view returns (bytes4) {
        return MAGICVALUE;
    }

    function withdraw(uint256 _amount, address _receiver) external view returns (bytes4) {
        if (_receiver != msg.sender) revert "Withdraw to other address is not allowed.";

        return MAGICVALUE;
    }
}
```

This filter allows the manager to call the function `deposit`, and the function `withdraw` if the receiver address is TeaVaultV2 (thus disallow the manager to withdraw funds to another address).

#### BypassFilter

If, for some reason (e.g. for testing), any function call for a smart contract should be allowed, one can use the BypassFilter smart contract as the filter.

#### ERC20Filter

ERC20Filter is a convenient filter for allowing ERC20 tokens to be approved for a target smart contract. A list of allowed spenders can be assigned in the filter.

#### Limitations

Right now, there is no way to check the value sent with the function. So a filter can't allow or decline a function call based only on how much native token is sent with the function. There is no simple way to work around this limitation on current architecture.

### Deployer

There is a separate TeaVaultV2Deployer, which uses CREATE2 to deploy TeaVaultV2 with pre-determined addresses. This can be used to deploy TeaVaultV2 with the same address on different chains.

## Set up

This project uses hardhat.

Use `npm install` to install required packages.

Copy `.env.example` into `.env` and add necessary settings.

Run `npx hardhat test` to run unit tests.

The script `deployDeployer.ts` is a simple script for deploying the TeaVaultV2Deployer contract.

The script `deploy.ts` uses TeaVaultV2Deployer to deploy a new TeaVaultV2 contract.
