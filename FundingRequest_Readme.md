# FundingRequest Contract

## Overview
The `FundingRequest` contract allows users to create funding requests for their projects and receive votes from others to assess the project's potential. Users can vote on the funding requests, either supporting or rejecting them. The contract maintains a list of active funding requests and provides functionality to retrieve them.

### Key Features
- Allows users to create a funding request with project details.
- Enables others to vote on funding requests, affecting their potential for success.
- Provides a method to retrieve all funding requests along with their details.

## Structs and State Variables

### FundingRequestStruct
- **projectName**: The name of the project requiring funding.
- **softCap**: The minimum amount required for the project to be considered successful (soft cap).
- **requiredAmount**: The total funding required for the project.
- **shortDescription**: A short description of the project.
- **country**: The country where the project is based.
- **websiteURL**: The website URL of the project.
- **ceoLinkedinURL**: The LinkedIn URL of the project's CEO.
- **companyRegistrationURL**: The URL for the company's registration document.
- **upVotes**: The total number of upvotes received for the funding request.
- **downVotes**: The total number of downvotes received for the funding request.
- **potentialAmountRaised**: The estimated amount that could be raised based on votes.
- **createdAt**: A timestamp of when the funding request was created.

### State Variables
- **mapping(address => FundingRequestStruct) public fundingRequests**: Maps an address to a `FundingRequestStruct`, storing the details of each funding request.
- **address[] public fundingRequestAddresses**: An array of addresses that keeps track of all funding request creators.
- **mapping(address => bool) public activeRequests**: Maps an address to a boolean indicating whether a funding request is active.
- **mapping(address => bool) public hasVotedForFundingRequest**: Maps voter addresses to a boolean indicating whether they have already voted for a funding request.

### Events
- **FundingRequestCreated(address requester, string projectName)**: Emitted when a new funding request is created.
- **FundingRequestVoted(address requester, bool upVote, address voter, uint256 voteWeight)**: Emitted when someone votes on a funding request.

## Functions

### `createFundingRequest()`
```solidity
function createFundingRequest(
    string memory _projectName,
    uint256 _softCap,
    uint256 _requiredAmount,
    string memory _shortDescription,
    string memory _country,
    string memory _websiteURL,
    string memory _ceoLinkedinURL,
    string memory _companyRegistrationURL
) public
```
This function allows a user to create a funding request for their project.

#### Parameters
- **_projectName**: Name of the project requiring funding.
- **_softCap**: The minimum amount required for the project.
- **_requiredAmount**: Total amount of funding required.
- **_shortDescription**: A brief description of the project.
- **_country**: The country where the project is located.
- **_websiteURL**: Website URL of the project.
- **_ceoLinkedinURL**: LinkedIn URL of the project's CEO.
- **_companyRegistrationURL**: Company registration document URL.

#### Logic and Explanation
1. **Validation Checks**: The function checks if the caller already has an active funding request.
   ```solidity
   require(!activeRequests[msg.sender], "Funding request already created.");
   require(bytes(fundingRequests[msg.sender].projectName).length == 0, "Funding request already created.");
   ```
   - If the caller already has an active request or a request with a non-empty `projectName`, the function reverts with an error message.

2. **Storing Data**: If the checks pass, the function creates a new `FundingRequestStruct` and stores it in the `fundingRequests` mapping.
   ```solidity
   fundingRequests[msg.sender] = FundingRequestStruct({
       projectName: _projectName,
       softCap: _softCap,
       requiredAmount: _requiredAmount,
       shortDescription: _shortDescription,
       country: _country,
       websiteURL: _websiteURL,
       ceoLinkedinURL: _ceoLinkedinURL,
       companyRegistrationURL: _companyRegistrationURL,
       upVotes: 0,
       downVotes: 0,
       potentialAmountRaised: 0,
       createdAt: block.timestamp
   });
   ```

3. **Marking Request as Active**: The function then marks the funding request as active and adds the address of the requester to the `fundingRequestAddresses` array.
   ```solidity
   activeRequests[msg.sender] = true;
   fundingRequestAddresses.push(msg.sender);
   ```

4. **Event Emission**: The function emits the `FundingRequestCreated` event.
   ```solidity
   emit FundingRequestCreated(msg.sender, _projectName);
   ```

### `voteOnFundingRequest()`
```solidity
function voteOnFundingRequest(address requester, bool upVote) public virtual
```
This function allows users to vote on an existing funding request.

#### Parameters
- **requester**: The address of the funding request creator.
- **upVote**: A boolean indicating whether the vote is an upvote (`true`) or a downvote (`false`).

#### Logic and Explanation
1. **Validation Checks**:
   - The function first checks if the voter has sufficient tokens to vote.
     ```solidity
     require(balanceOf(msg.sender) >= 1, "You do not have sufficient INV4 tokens to vote.");
     ```
   - It then checks if the caller has already voted for a funding request.
     ```solidity
     require(!hasVotedForFundingRequest[msg.sender], "You have already voted on a funding request.");
     ```
   - Finally, it ensures that the requester cannot vote on their own funding request.
     ```solidity
     require(requester != msg.sender, "You cannot vote on your own funding request.");
     ```

2. **Calculating Voting Weight**: The function calculates the voting weight based on the voter's token balance.
   ```solidity
   uint256 voteWeight = balanceOf(msg.sender) / 500;
   require(voteWeight >= 1, "You do not have sufficient voting power to vote.");
   ```

3. **Recording Vote**: Depending on whether the vote is an upvote or downvote, the relevant counters are incremented or decremented.
   ```solidity
   if (upVote) {
       fundingRequests[requester].upVotes += voteWeight;
       fundingRequests[requester].potentialAmountRaised += voteWeight;
   } else {
       fundingRequests[requester].downVotes += voteWeight;
       fundingRequests[requester].potentialAmountRaised -= voteWeight;
   }
   ```

4. **Marking Voter**: The address of the voter is marked as having voted.
   ```solidity
   hasVotedForFundingRequest[msg.sender] = true;
   ```

5. **Event Emission**: The function emits the `FundingRequestVoted` event.
   ```solidity
   emit FundingRequestVoted(requester, upVote, msg.sender, voteWeight);
   ```

### `getAllFundingRequests()`
```solidity
function getAllFundingRequests() public view returns (FundingRequestStruct[] memory, address[] memory)
```
This function allows anyone to retrieve the list of all funding requests along with their details.

#### Return Values
- **FundingRequestStruct[] memory**: An array containing all the funding requests and their details.
- **address[] memory**: An array of all funding request creator addresses.

#### Logic and Explanation
1. **Array Creation**: The function creates arrays to hold all funding requests and their addresses.
   ```solidity
   FundingRequestStruct[] memory allFundingRequests = new FundingRequestStruct[](len);
   address[] memory addresses = new address[](len);
   ```

2. **Populating Arrays**: The function populates the arrays with the details of all registered funding requests.
   ```solidity
   for (uint256 i = 0; i < len; i++) {
       allFundingRequests[i] = fundingRequests[fundingRequestAddresses[i]];
       addresses[i] = fundingRequestAddresses[i];
   }
   ```

3. **Returning Data**: Finally, the function returns the populated arrays.
   ```solidity
   return (allFundingRequests, addresses);
   ```

### `balanceOf()`
```solidity
function balanceOf(address account) public view virtual returns (uint256)
```
This abstract function is used to return the token balance of an account. The implementation is expected in derived contracts.

#### Parameters
- **account**: The address of the account whose token balance is being queried.

#### Logic and Explanation
- Since this function is marked as `abstract`, it does not have an implementation in this contract. Derived contracts are required to provide the logic for calculating the token balance.

## Usage Example
1. **Create a Funding Request**: Users can call `createFundingRequest()` with their project details to create a new funding request.
2. **Vote on a Funding Request**: Users can call `voteOnFundingRequest()` to vote on an existing funding request, either upvoting or downvoting it.
3. **Retrieve All Funding Requests**: Anyone can call `getAllFundingRequests()` to get a list of all funding requests and their details.

## Key Considerations
- **One Active Request**: Each address can only create one active funding request at a time. Attempting to create multiple requests will revert with an error.
- **Voting Power**: Voting power is based on the voter's token balance, which means that users with more tokens have a larger influence.
- **Voting Restriction**: A user can only vote for one funding request at a time. Voting for multiple requests is not allowed.

## Conclusion
The `FundingRequest` contract allows users to create funding requests for their projects and receive community votes to assess the project's viability. It maintains a list of all funding requests and allows users to upvote or downvote based on their token balance, thereby providing a way to gauge community interest and potential for success.

