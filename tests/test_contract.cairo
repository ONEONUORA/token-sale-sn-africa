use core::array::ArrayTrait;
use core::traits::{Into, TryInto};
use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use starknet::ContractAddress;
use token_sale::interfaces::itoken_sale::{ITokenSaleDispatcher, ITokenSaleDispatcherTrait};


const OWNER: ContractAddress = 'owner'.try_into().unwrap();
const BUYER: ContractAddress = 'buyer'.try_into().unwrap();
fn deploy_contract() -> (ITokenSaleDispatcher, ContractAddress, ContractAddress) {
    let initial_supply = 1000000000000000000000000_u256; // 1 million tokens with 18 decimals

    // Declare the contract
    let contract_class = declare("MyToken").unwrap().contract_class();

    // Create constructor calldata
    let mut constructor_calldata = array![];
    constructor_calldata.append(initial_supply.low.into());
    constructor_calldata.append(initial_supply.high.into());
    constructor_calldata.append(OWNER.into());

    // Deploy the contract
    let (erc20_address, _) = contract_class.deploy(@constructor_calldata).unwrap();

    let contract_class = declare("TokenSale").unwrap().contract_class();

    let (contract_address, _) = contract_class
        .deploy(@array![OWNER.into(), erc20_address.into()])
        .unwrap();
    let dispatcher = ITokenSaleDispatcher { contract_address };
    (dispatcher, erc20_address, contract_address)
}

#[test]
fn test_check_available_token() {
    let (dispatcher, erc20_address, contract_address) = deploy_contract();

    // Initialize ERC20 dispatcher
    let erc20: IERC20Dispatcher = IERC20Dispatcher { contract_address: erc20_address };

    // Transfer tokens to TokenSale contract
    start_cheat_caller_address(erc20_address, OWNER);
    erc20.transfer(contract_address, 100_000_000_000_000_000_000); // Transfer 100 tokens
    stop_cheat_caller_address(erc20_address);

    let available_token = dispatcher.check_available_token(erc20_address);
    assert!(available_token == 100_000_000_000_000_000_000, "Incorrect token balance");
}


#[test]
fn test_check_deposit_token() {
    let (dispatcher, erc20_address, contract_address) = deploy_contract();

    // Initialize ERC20 dispatcher
    let erc20: IERC20Dispatcher = IERC20Dispatcher { contract_address: erc20_address };

    start_cheat_caller_address(erc20_address, OWNER);
    erc20.transfer(OWNER, 100_000_000_000_000_000_000);
    // approve contract to spend
    erc20.approve(contract_address, 100_000_000_000_000_000_000);
    stop_cheat_caller_address(erc20_address);

    start_cheat_caller_address(contract_address, OWNER);
    dispatcher.deposit_token(erc20_address, 100_000_000_000, 23);
    stop_cheat_caller_address(contract_address);
}


#[test]
fn test_check_buy_token() {
    let (dispatcher, erc20_address, contract_address) = deploy_contract();

    // Initialize ERC20 dispatcher
    let erc20: IERC20Dispatcher = IERC20Dispatcher { contract_address: erc20_address };

    start_cheat_caller_address(erc20_address, OWNER);
    erc20.transfer(OWNER, 100_000_000_000_000_000);
    erc20.transfer(BUYER, 100_00);
    // approve contract to spend
    erc20.approve(contract_address, 100_000_000_000_000_000);
    stop_cheat_caller_address(erc20_address);

    start_cheat_caller_address(contract_address, OWNER);
    dispatcher.deposit_token(erc20_address, 100_000_000_000, 23);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, BUYER);
    dispatcher.buy_token(erc20_address, 100_000_000_000);
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_upgradability() {
    let initial_supply = 1000000000000000000000000_u256; // 1 million tokens with 18 decimals
    let token_contract = declare("MyToken").unwrap().contract_class();

    // Create constructor calldata
    let mut constructor_calldata = array![];
    constructor_calldata.append(initial_supply.low.into());
    constructor_calldata.append(initial_supply.high.into());
    constructor_calldata.append(OWNER.into());

    // Deploy the contract
    let (erc20_address, _) = token_contract.deploy(@constructor_calldata).unwrap();

    let contract_class = declare("TokenSale").unwrap().contract_class();

    let (contract_address, _) = contract_class
        .deploy(@array![OWNER.into(), erc20_address.into()])
        .unwrap();

    let instance = ITokenSaleDispatcher { contract_address };
    // declaring for a new class hash
    let new_class_hash = declare("TokenSale").unwrap().contract_class().class_hash;
    start_cheat_caller_address(contract_address, OWNER);
    instance.upgrade(*new_class_hash);
}