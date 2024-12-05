# Invtron Contract

## Overview
The `Invtron` contract is an advanced Ethereum-based smart contract that extends the functionality of the ERC20 token with additional features like voting mechanisms, CEO applications, funding request creation, user registration, and endorsement processes. The contract combines multiple modules into one coherent platform, facilitating a wide range of features that allow community governance and user interaction through token-based incentives.

### Key Features
- **ERC20 Token Integration**: Standard token functionality with a fixed total supply.
- **Voting Mechanisms**: Users can vote on funding requests and endorsements, which affect their community standing and participation eligibility.
- **CEO Application and User Registration**: Users can register as CEOs or regular users, and create funding requests for their projects.
- **Endorsement and Governance**: Supports endorsement applications and voting to elect community leaders or endorse others.

## Structs and State Variables

### Transaction Struct
- **timestamp**: The timestamp of when the transaction occurred.
- **amount**: The amount of tokens transferred in the transaction.

### State Variables
- **uint256 public constant VOTE_DURATION**: Defines the duration for voting on funding requests and endorsements (72 hours).
- **uint256 public constant VOTE_PERCENTAGE**: Percentage used for voting mechanisms.
- **uint256 public constant VOTE_LOOKBACK_PERIOD**: Lookback period for calculating voting power (10 minutes).
- **mapping(address => Transaction[]) public outgoingTransactions**: Maps an address to its list of outgoing transactions, used for calculating voting power.
- **mapping(address => uint256) public initialBalances**: Stores the initial token balance of each address when they start interacting with the platform.

### Events
- **ApplicantRegistered(address applicant, string firstName, string lastName)**: Emitted when a new applicant is registered.

## Functions

### `constructor()`
```solidity
constructor() ERC20("Invtron", "INV4")
```
The constructor initializes the contract by minting a total supply of tokens and setting aside a reserve for the contract itself.

#### Logic and Explanation
1. **Token Initialization**: The contract mints a total supply of 1 billion `INV4` tokens.
   ```solidity
   uint256 totalSupply = 1_000_000_000 * (10**uint256(decimals()));
   _mint(msg.sender, totalSupply);
   ```

2. **Contract Reserve**: 10% of the total supply is transferred to the contract address as a reserve.
   ```solidity
   uint256 reserveForContract = totalSupply / 10;
   _transfer(msg.sender, address(this), reserveForContract);
   ```

### `calculateVotingPower()`
```solidity
function calculateVotingPower(address voter) public view override returns (uint256)
```
This function calculates the voting power of an address based on its initial balance and outgoing transactions.

#### Parameters
- **voter**: The address of the voter whose voting power needs to be calculated.

#### Logic and Explanation
1. **Calculate Outgoing Tokens**: Uses the `getOutgoingTokens()` function to get the total amount of tokens sent by the voter during the lookback period.
   ```solidity
   uint256 totalOutgoingTokens = getOutgoingTokens(voter, VOTE_LOOKBACK_PERIOD);
   ```

2. **Calculate Voting Power**: Voting power is derived by subtracting the total outgoing tokens from the initial balance.
   ```solidity
   uint256 initialBalance = initialBalances[voter];
   return initialBalance - totalOutgoingTokens;
   ```

### `getOutgoingTokens()`
```solidity
function getOutgoingTokens(address voter, uint256 lookbackPeriod) public view returns (uint256)
```
This function calculates the total outgoing tokens from an address during a given lookback period.

#### Parameters
- **voter**: The address whose outgoing transactions are being queried.
- **lookbackPeriod**: The time period within which outgoing tokens are counted.

#### Logic and Explanation
1. **Iterate Through Transactions**: Loops through the `outgoingTransactions` of the address to calculate the total outgoing tokens within the given lookback period.
   ```solidity
   for (uint256 i = transactions.length; i > 0; i--) {
       if (transactions[i - 1].timestamp + lookbackPeriod < currentTime) {
           break;
       }
       outgoingTokens += transactions[i - 1].amount;
   }
   ```

2. **Return Result**: Returns the total outgoing tokens.
   ```solidity
   return outgoingTokens;
   ```

### `_transfer()`
```solidity
function _transfer(address sender, address recipient, uint256 amount) internal virtual override
```
Overrides the standard ERC20 `_transfer()` function to add custom behavior for tracking outgoing transactions and calculating voting power.

#### Parameters
- **sender**: The address sending the tokens.
- **recipient**: The address receiving the tokens.
- **amount**: The amount of tokens being transferred.

#### Logic and Explanation
1. **Call Super `_transfer()`**: Calls the original `_transfer()` function from ERC20 to execute the token transfer.
   ```solidity
   super._transfer(sender, recipient, amount);
   ```

2. **Track Outgoing Transaction**: Records the outgoing transaction for the sender.
   ```solidity
   outgoingTransactions[sender].push(Transaction({
       timestamp: block.timestamp,
       amount: amount
   }));
   ```

3. **Clean Old Transactions**: Calls `cleanOldTransactions()` to remove transactions outside the lookback period.
   ```solidity
   cleanOldTransactions(sender);
   ```

4. **Update Initial Balance**: Sets the initial balance for the sender if it hasn't been set previously.
   ```solidity
   if (initialBalances[sender] == 0) {
       initialBalances[sender] = balanceOf(sender) + amount;
   }
   ```

### `cleanOldTransactions()`
```solidity
function cleanOldTransactions(address sender) internal
```
This function removes transactions that fall outside the lookback period from the outgoing transaction history of an address.

#### Parameters
- **sender**: The address whose transactions are being cleaned.

#### Logic and Explanation
1. **Iterate Through Transactions**: Loops through the transactions and removes those that are older than the `VOTE_LOOKBACK_PERIOD`.
   ```solidity
   if (transactions[i].timestamp + VOTE_LOOKBACK_PERIOD < currentTime) {
       transactions[i] = transactions[transactions.length - 1];
       transactions.pop();
       i--;
   }
   ```

### `getRemainingVoteTime()`
```solidity
function getRemainingVoteTime(address requestAddress, bool isFundingRequest) public view returns (uint256)
```
This function calculates the remaining time available for voting on a funding request or an endorsement application.

#### Parameters
- **requestAddress**: The address of the request for which the vote time is being queried.
- **isFundingRequest**: Boolean indicating whether the request is a funding request or an endorsement.

#### Logic and Explanation
1. **Check Request Type**: Determines whether the request is a funding request or an endorsement and retrieves the corresponding struct.
2. **Calculate End Time**: Calculates the voting end time based on the request's creation timestamp and the `VOTE_DURATION`.
3. **Return Remaining Time**: If the current time is past the end time, returns 0; otherwise, returns the remaining time.

### `balanceOf()`
```solidity
function balanceOf(address account) public view override(ERC20, FundingRequest) returns (uint256)
```
Overrides the `balanceOf()` function from both the ERC20 and FundingRequest contracts.

#### Parameters
- **account**: The address whose token balance is being queried.

#### Logic and Explanation
- Calls the `balanceOf()` function from the ERC20 implementation to return the balance.
  ```solidity
  return super.balanceOf(account);
  ```

## Usage Example
1. **Deploy the Contract**: Deploy the `Invtron` contract to create the `INV4` tokens.
2. **Register as a User or CEO**: Users can call the respective functions to register themselves as regular users or CEOs.
3. **Create Funding Requests**: Registered CEOs can create funding requests for their projects.
4. **Vote on Requests**: Users can vote on funding requests or endorsement applications using their token balance as voting power.

## Key Considerations
- **Voting Power**: Voting power is calculated based on the initial token balance of a voter, reduced by their outgoing transactions within the lookback period.
- **Token Supply**: A fixed total supply of 1 billion `INV4` tokens is minted, with 10% reserved for the contract.
- **Voting Duration**: Voting for both funding requests and endorsements lasts for 72 hours.

## Conclusion
The `Invtron` contract is a comprehensive solution that integrates ERC20 token functionality with advanced features like user registration, funding requests, CEO applications, and endorsement mechanisms. The voting system ensures community-driven decision-making, with voting power tied to token holdings and transaction history, making it suitable for decentralized governance and project funding initiatives.

