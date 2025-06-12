# TokenSale Contract

A comprehensive Cairo smart contract for conducting token sales on StarkNet, built with OpenZeppelin components for security and upgradeability.

## Overview

The TokenSale contract enables secure token sales where users can purchase tokens using a specified payment token. The contract incorporates OpenZeppelin's Ownable and Upgradeable components to ensure proper access control and future upgradability.

## Features

- **Token Sales Management**: Deposit tokens for sale and set pricing
- **Secure Purchasing**: Users can buy tokens using accepted payment tokens
- **Owner Access Control**: Utilizes OpenZeppelin Ownable component for secure ownership management
- **Upgradeable**: Built with OpenZeppelin Upgradeable component for future improvements
- **Balance Checking**: Real-time availability checking for tokens
- **Multi-token Support**: Support for multiple token sales simultaneously

## Architecture

### Components Used

- **OpenZeppelin Ownable**: Provides secure ownership management with standardized access control
- **OpenZeppelin Upgradeable**: Enables contract upgrades while preserving state
- **Custom Interfaces**: `ITokenSale` and `IERC20` for standardized interactions

### Storage Structure

```cairo
struct Storage {
    accepted_payment_token: ContractAddress,     // Token used for payments
    token_price: Map<ContractAddress, u256>,     // Price mapping for each token
    tokens_available_for_sale: Map<ContractAddress, u256>, // Available token amounts
    upgradeable: UpgradeableComponent::Storage,  // Upgrade functionality storage
    ownable: OwnableComponent::Storage,          // Ownership management storage
}
```

## Functions

### Public Functions

#### `check_available_token(token_address: ContractAddress) -> u256`
Returns the current balance of a specific token held by the contract.

**Parameters:**
- `token_address`: The address of the token to check

**Returns:**
- `u256`: Current token balance in the contract

#### `deposit_token(token_address: ContractAddress, amount: u256, token_price: u256)`
Allows the owner to deposit tokens for sale and set their price.

**Parameters:**
- `token_address`: Address of the token to deposit
- `amount`: Amount of tokens to deposit
- `token_price`: Price per token unit

**Access:** Owner only

**Requirements:**
- Caller must be the contract owner
- Owner must have sufficient balance of the payment token
- Transfer must succeed

#### `buy_token(token_address: ContractAddress, amount: u256)`
Enables users to purchase tokens using the accepted payment token.

**Parameters:**
- `token_address`: Address of the token to purchase
- `amount`: Amount of tokens to buy (must match exactly available amount)

**Requirements:**
- Amount must exactly match available tokens for sale
- Buyer must have sufficient payment token balance
- All transfers must succeed

#### `upgrade(new_class_hash: ClassHash)`
Upgrades the contract to a new implementation.

**Parameters:**
- `new_class_hash`: Hash of the new contract class

**Access:** Owner only

**Security:** Uses OpenZeppelin's `assert_only_owner()` for access control

### Inherited Functions (OpenZeppelin Ownable)

- `owner() -> ContractAddress`: Returns the current owner
- `transfer_ownership(new_owner: ContractAddress)`: Transfers ownership
- `renounce_ownership()`: Renounces ownership (makes contract ownerless)

## Installation & Setup

### Prerequisites

- Cairo compiler (latest version)
- StarkNet development environment
- OpenZeppelin Cairo contracts library

### Dependencies

Add to your `Scarb.toml`:

```toml
[dependencies]
openzeppelin = { git = "https://github.com/OpenZeppelin/cairo-contracts.git", tag = "v0.10.0" }
starknet = ">=2.0.0"
```

### Compilation

```bash
scarb build
```

### Deployment

```bash
starkli deploy target/dev/your_project_TokenSale.contract_class.json \
  --constructor-calldata <owner_address> <accepted_payment_token_address>
```

## Usage Examples

### Deploying the Contract

```cairo
// Constructor parameters
let owner = 0x123...; // Owner address
let payment_token = 0x456...; // Accepted payment token address

// Deploy with these parameters
```

### Depositing Tokens for Sale

```cairo
// As contract owner
let token_address = 0x789...; // Token to sell
let amount = 1000000000000000000; // 1 token (assuming 18 decimals)
let price = 500000000000000000; // 0.5 payment tokens per token

contract.deposit_token(token_address, amount, price);
```

### Buying Tokens

```cairo
// As a buyer
let token_address = 0x789...; // Token to buy
let amount = 1000000000000000000; // Amount to buy

// First approve the contract to spend your payment tokens
payment_token.approve(contract_address, required_payment_amount);

// Then buy the tokens
contract.buy_token(token_address, amount);
```

### Checking Token Availability

```cairo
let available = contract.check_available_token(token_address);
```

## Security Considerations

### Access Control
- Critical functions are protected by OpenZeppelin's Ownable component
- Owner-only functions use `assert_only_owner()` for secure access control
- Ownership can be transferred or renounced following OpenZeppelin standards

### Transfer Safety
- All token transfers are validated with assertions
- Balance checks ensure sufficient funds before transfers
- Failed transfers will revert the entire transaction

### Upgrade Safety
- Contract upgrades are restricted to the owner only
- Uses OpenZeppelin's battle-tested upgrade mechanism
- State preservation during upgrades

## Testing

### Unit Tests

Create comprehensive tests covering:

```cairo
#[cfg(test)]
mod tests {
    // Test deployment
    // Test token deposits
    // Test token purchases
    // Test access control
    // Test upgrade functionality
    // Test edge cases and error conditions
}
```

### Integration Tests

- Test with real ERC20 tokens
- Test ownership transfer scenarios
- Test upgrade scenarios
- Test multi-token sale scenarios

## Events

The contract emits events from OpenZeppelin components:

- **OwnershipTransferred**: When ownership changes
- **Upgraded**: When contract is upgraded

## Error Handling

Common error messages:
- `'Unauthorized'`: Caller is not the owner
- `'insufficient balance'`: Insufficient token balance
- `'transfer failed'`: Token transfer failed
- `'insufficient funds'`: Buyer doesn't have enough payment tokens
- `"amount must be exact"`: Purchase amount doesn't match available tokens

## Best Practices

### For Contract Owners
- Always test upgrades on testnet first
- Verify token addresses before depositing
- Monitor contract balances regularly
- Use multi-signature wallets for production deployments

### For Buyers
- Check token availability before attempting purchases
- Ensure sufficient payment token balance and approval
- Verify token authenticity before purchasing

## Roadmap

### Potential Improvements
- Partial purchase support (not requiring exact amount)
- Multiple payment token support
- Auction mechanisms
- Vesting schedules
- Whitelist functionality
- Discount mechanisms

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with comprehensive tests
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Deployment Address
The contract will be deployed at address 0x0206b36d6626c1d2c01cfee4885043b8b10ee27d69153086997166177a33bba3

## Support

For questions and support:
- Create an issue in the repository
- Join the StarkNet community Discord
- Check OpenZeppelin documentation for component-specific questions

## Acknowledgments

- OpenZeppelin for secure smart contract components
- StarkWare for the Cairo language and StarkNet platform
- The Cairo and StarkNet community for continuous support and development