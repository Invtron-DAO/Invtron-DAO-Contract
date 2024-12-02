# Invtron4 Smart Contract

### Table of Contents
1. Introduction
2. Features
3. Contract Inheritance and Dependencies
4. Tokenomics
5. Voting Mechanism
6. Sub-Contracts Overview
7. Functions Overview
8. How to Deploy
9. License

## Introduction
Invtron4 is an ERC20 token contract with extended functionality for user voting, CEO applications, funding request management, and user registration. It integrates traditional tokenomics with governance mechanisms to foster a decentralized platform for managing various roles and funding requests within the ecosystem.

### Token Details:
- **Token Name**: Invtron4
- **Token Symbol**: INV4
- **Total Supply**: 1,000,000,000 INV4

## Features
- **ERC20 Token**: Standard fungible token compliant with the ERC20 specification.
- **Voting Mechanism**: Token holders can vote for endorsers and funding requests using their voting power.
- **CEO Application Process**: Users can apply for CEO roles, which are subject to community voting.
- **Funding Requests**: Users can create funding requests that can be reviewed and voted upon by token holders.
- **User Registration**: Functionality to register users, enhancing participation transparency.

## Contract Inheritance and Dependencies
The `Invtron4` smart contract inherits and utilizes multiple contracts from OpenZeppelin and custom imports. Below is an overview of all the inherited contracts:

1. **ERC20** (OpenZeppelin): Base for the ERC20 token standard functionality.
2. **Ownable** (OpenZeppelin): Allows control of ownership to manage permissions effectively.
3. **ReentrancyGuard** (OpenZeppelin): Ensures protection against reentrancy attacks.
4. **Endorser** (Custom): Handles functionality related to endorsing users.
5. **FundingRequest** (Custom): Provides mechanisms for users to create funding requests.
6. **UserRegistration** (Custom): Implements user registration.
7. **CeoRegistration** (Custom): Adds the functionality for CEO application and registration.

## Tokenomics
The Invtron4 token contract was deployed with the following tokenomics:
- **Initial Total Supply**: 1,000,000,000 INV4.
- **Reserve Allocation**: 10% of the total supply (100,000,000 INV4) is reserved for the contract to be used for project and ecosystem development.
- **Decimals**: Uses the standard ERC20 decimals function for 18 decimals.

## Voting Mechanism
The Invtron4 contract incorporates a voting mechanism for the endorsement of applicants and funding requests. The voting system is based on the following:

- **Voting Duration**: 72 hours from the time of creation.
- **Voting Power Calculation**: Voting power is based on the difference between the initial balance and outgoing tokens sent by the voter.
- **Lookback Period**: Outgoing transactions within a specified lookback period of 10 minutes are considered when determining voting power.

### Voting Power Calculation
The `calculateVotingPower` function calculates the voting power for a user based on their initial token balance minus the total outgoing tokens sent within the defined lookback period. This method helps prevent vote manipulation by limiting frequent transfers during active voting.

## Sub-Contracts Overview
The Invtron4 contract relies on several sub-contracts, each providing specific functionality:

### 1. CeoRegistration.sol
This contract manages CEO applications and registrations.
- **Structures**:
  - `Ceo`: Contains information such as name, address, city, and more.
- **Functions**:
  - `becomeCeo`: Registers a user as a CEO candidate.
  - `getAllCeos`: Returns all registered CEOs along with their addresses.

### 2. Endorser.sol
This contract manages the endorsement process, allowing users to endorse applicants.
- **Structures**:
  - `EndorserApplicant`: Stores details such as name, address, bio, and voting information.
- **Functions**:
  - `becomeEndorser`: Allows a user to apply as an endorser.
  - `voteOnEndorser`: Facilitates voting on endorser applications.
  - `getAllEndorsers`: Retrieves all registered endorsers with their voting data.
  - `calculateVotingPower`: Abstract function that determines the voting power of a user.

### 3. FundingRequest.sol
This contract handles funding request management.
- **Structures**:
  - `FundingRequestStruct`: Contains project details such as soft cap, required amount, and voting data.
- **Functions**:
  - `createFundingRequest`: Allows users to create funding requests.
  - `voteOnFundingRequest`: Allows users to vote on existing funding requests.
  - `getAllFundingRequests`: Returns all funding requests with their details.
  - `balanceOf`: Abstract function to get the token balance of an account.

### 4. UserRegistration.sol
This contract manages user registration.
- **Structures**:
  - `User`: Stores user details like name, address, interests, and contact information.
- **Functions**:
  - `registerUser`: Registers a user in the system.
  - `updateUser`: Updates an existing user's details.
  - `getAllUsers`: Returns all registered users and their addresses.

## Functions Overview
### Core Functions in Invtron4
1. **Constructor**: 
   Initializes the contract with the token name, symbol, and total supply. Allocates 10% of the supply to the contract itself for developmental purposes.

2. **calculateVotingPower(address voter)**:
   Calculates and returns the voting power of the provided address.

3. **getOutgoingTokens(address voter, uint256 lookbackPeriod)**:
   Returns the total outgoing tokens sent by a given address within the specified lookback period.

4. **_transfer(address sender, address recipient, uint256 amount)**:
   Overrides the ERC20 `_transfer` function to log outgoing transactions and ensure consistency of initial balances for voters.

5. **cleanOldTransactions(address sender)**:
   Removes old transactions from the outgoing transaction history if they fall outside the lookback period.

6. **getRemainingVoteTime(address requestAddress, bool isFundingRequest)**:
   Returns the remaining voting time for a given funding request or endorsement application.

7. **balanceOf(address account)**:
   Overrides the balanceOf function to ensure compatibility between ERC20 and FundingRequest.

### Events
- **ApplicantRegistered(address applicant, string firstName, string lastName)**: 
  Emitted when a new user applies to become a CEO.
- **CeoRegistered(address indexed ceo, string firstName, string lastName, string mobile, string postcode, string residentAddress, string city, string state, string country, string about)**: 
  Emitted when a new CEO is registered.
- **EndorserApplicantRegistered(address applicant, string firstName, string lastName)**: 
  Emitted when a user applies to become an endorser.
- **EndorserVoted(address endorser, bool upVote, address voter, uint256 voteWeight)**: 
  Emitted when a vote is cast for an endorser.
- **FundingRequestCreated(address requester, string projectName)**: 
  Emitted when a new funding request is created.
- **FundingRequestVoted(address requester, bool upVote, address voter, uint256 voteWeight)**: 
  Emitted when a vote is cast on a funding request.
- **UserRegistered(address indexed user, string firstName, string lastName)**: 
  Emitted when a user registers.
- **UserUpdated(address indexed user, string firstName, string lastName)**: 
  Emitted when a user updates their details.
  
## License
This project is licensed under the MIT License. See the LICENSE file for more information.

