# Endorser Contract

## Overview
The `Endorser` contract allows users to apply to become endorsers by registering their details and enables others to vote on these applicants. Each applicant receives votes that determine their endorsement status, and only the top endorsers are marked as active. The contract also includes functions for retrieving the list of endorsers and for voting on them.

### Key Features
- Allows users to apply to become an endorser by providing personal details.
- Provides a voting system for others to upvote or downvote endorsers.
- Maintains a ranked list of endorsers and marks only the top ones as active.

## Structs and State Variables

### EndorserApplicant Struct
- **firstName**: The first name of the endorser applicant.
- **lastName**: The last name of the endorser applicant.
- **mobile**: The mobile number of the endorser applicant.
- **postcode**: The postcode of the applicant's residential address.
- **addressDetails**: Detailed residential address of the applicant.
- **country**: The country of residence of the applicant.
- **bio**: A short biography or description of the applicant.
- **upVotes**: The total number of upvotes received by the applicant.
- **downVotes**: The total number of downvotes received by the applicant.
- **active**: A boolean indicating whether the applicant is an active endorser.
- **createdAt**: A timestamp of when the applicant registered.

### State Variables
- **mapping(address => EndorserApplicant) public endorserApplicants**: Maps an Ethereum address to an `EndorserApplicant` struct, storing the details of each applicant.
- **address[] public endorserAddresses**: An array of addresses that keeps track of all registered endorser applicants.
- **mapping(address => bool) public hasVotedForEndorser**: Maps voter addresses to a boolean, indicating whether they have already voted for an endorser.

### Events
- **EndorserApplicantRegistered(address applicant, string firstName, string lastName)**: Emitted when a new endorser registers.
- **EndorserVoted(address endorser, bool upVote, address voter, uint256 voteWeight)**: Emitted when someone votes for an endorser.

## Functions

### `becomeEndorser()`
```solidity
function becomeEndorser(
    string memory _firstName,
    string memory _lastName,
    string memory _mobile,
    string memory _postcode,
    string memory _address,
    string memory _country,
    string memory _bio
) public
```
This function allows a user to register themselves as an endorser.

#### Parameters
- **_firstName**: First name of the endorser applicant.
- **_lastName**: Last name of the endorser applicant.
- **_mobile**: Mobile number of the endorser applicant.
- **_postcode**: Postcode of the residential address.
- **_address**: Detailed residential address.
- **_country**: Country of residence.
- **_bio**: A short description or biography.

#### Logic and Explanation
1. **Registration Check**: The function first checks if the sender is already registered as an endorser.
   ```solidity
   require(bytes(endorserApplicants[msg.sender].firstName).length == 0, "Endorser already registered.");
   ```
   - If the `firstName` of the `EndorserApplicant` struct at `msg.sender` is non-empty, it indicates that the sender is already registered, and the function reverts with an error message.

2. **Storing Data**: If the sender is not registered, the function stores the provided information in the `endorserApplicants` mapping, creating a new `EndorserApplicant` struct.
   ```solidity
   endorserApplicants[msg.sender] = EndorserApplicant({
       firstName: _firstName,
       lastName: _lastName,
       mobile: _mobile,
       postcode: _postcode,
       addressDetails: _address,
       country: _country,
       bio: _bio,
       upVotes: 0,
       downVotes: 0,
       active: false,
       createdAt: block.timestamp
   });
   ```
   - The new `EndorserApplicant` struct is created and assigned to the address of the sender (`msg.sender`).

3. **Tracking Registered Endorsers**: The address of the newly registered endorser is added to the `endorserAddresses` array.
   ```solidity
   endorserAddresses.push(msg.sender);
   ```

4. **Event Emission**: Finally, the function emits the `EndorserApplicantRegistered` event.
   ```solidity
   emit EndorserApplicantRegistered(msg.sender, _firstName, _lastName);
   ```

### `voteOnEndorser()`
```solidity
function voteOnEndorser(address endorser, bool upVote) public virtual
```
This function allows users to vote on an endorser applicant, either upvoting or downvoting them.

#### Parameters
- **endorser**: The address of the endorser applicant to be voted on.
- **upVote**: A boolean indicating whether the vote is an upvote (`true`) or a downvote (`false`).

#### Logic and Explanation
1. **Validation Checks**:
   - The function first checks if the provided address (`endorser`) is registered as an endorser.
     ```solidity
     require(bytes(endorserApplicants[endorser].firstName).length != 0, "Not a registered endorser.");
     ```
   - It then checks if the caller has already voted for an endorser.
     ```solidity
     require(!hasVotedForEndorser[msg.sender], "You can only vote on one endorser at a time.");
     ```
   - Finally, it ensures that an applicant cannot vote on their own endorsement request.
     ```solidity
     require(endorser != msg.sender, "You cannot vote on your own endorser request.");
     ```

2. **Calculating Voting Power**: The function calculates the voting power of the voter.
   ```solidity
   uint256 voteWeight = calculateVotingPower(msg.sender);
   require(voteWeight >= 1, "You do not have sufficient voting power to vote.");
   ```
   - The `calculateVotingPower()` function is called to determine how much weight the voter's vote carries.

3. **Recording Vote**: Depending on whether the vote is an upvote or downvote, the relevant counter is incremented.
   ```solidity
   if (upVote) {
       endorserApplicants[endorser].upVotes += voteWeight;
   } else {
       endorserApplicants[endorser].downVotes += voteWeight;
   }
   ```

4. **Marking Voter**: The address of the voter is marked as having voted.
   ```solidity
   hasVotedForEndorser[msg.sender] = true;
   ```

5. **Event Emission**: The function emits the `EndorserVoted` event.
   ```solidity
   emit EndorserVoted(endorser, upVote, msg.sender, voteWeight);
   ```

6. **Updating Endorser Status**: The function calls `updateEndorserStatus()` to determine the top endorsers.
   ```solidity
   updateEndorserStatus();
   ```

### `updateEndorserStatus()`
```solidity
function updateEndorserStatus() internal
```
This internal function updates the endorsement status of all applicants by marking only the top three as active.

#### Logic and Explanation
1. **Array Creation**: The function first creates memory arrays to hold all endorsers and their addresses.
   ```solidity
   EndorserApplicant[] memory endorsers = new EndorserApplicant[](len);
   address[] memory addresses = new address[](len);
   ```

2. **Populating Arrays**: It populates the arrays with the current endorsers and their addresses.
   ```solidity
   for (uint256 i = 0; i < len; i++) {
       address addr = endorserAddresses[i];
       endorsers[i] = endorserApplicants[addr];
       addresses[i] = addr;
   }
   ```

3. **Sorting Endorsers**: The endorsers are sorted by their net votes (upvotes minus downvotes).
   ```solidity
   for (uint256 i = 0; i < len; i++) {
       for (uint256 j = i + 1; j < len; j++) {
           int256 votesI = int256(endorsers[i].upVotes) - int256(endorsers[i].downVotes);
           int256 votesJ = int256(endorsers[j].upVotes) - int256(endorsers[j].downVotes);
           if (votesI < votesJ) {
               EndorserApplicant memory tempEndorser = endorsers[i];
               endorsers[i] = endorsers[j];
               endorsers[j] = tempEndorser;

               address tempAddress = addresses[i];
               addresses[i] = addresses[j];
               addresses[j] = tempAddress;
           }
       }
   }
   ```

4. **Updating Endorser Status**: Finally, the function marks the top three endorsers as active.
   ```solidity
   for (uint256 i = 0; i < len; i++) {
       address addr = endorserAddresses[i];
       endorserApplicants[addr].active = i < 3;
   }
   ```

### `getAllEndorsers()`
```solidity
function getAllEndorsers() public view returns (EndorserApplicant[] memory, address[] memory)
```
This function allows anyone to retrieve the list of all endorsers along with their details.

#### Return Values
- **EndorserApplicant[] memory**: An array of all endorser applicants and their details.
- **address[] memory**: An array of all endorser applicant addresses.

#### Logic and Explanation
1. **Array Creation**: The function creates arrays to hold the endorsers and their addresses.
   ```solidity
   EndorserApplicant[] memory allEndorsers = new EndorserApplicant[](len);
   address[] memory addresses = new address[](len);
   ```

2. **Populating Arrays**: The arrays are populated with the details of all registered endorsers.
   ```solidity
   for (uint256 i = 0; i < len; i++) {
       allEndorsers[i] = endorserApplicants[endorserAddresses[i]];
       addresses[i] = endorserAddresses[i];
   }
   ```

3. **Sorting Endorsers**: The endorsers are sorted by their net votes (upvotes minus downvotes).
   ```solidity
   for (uint256 i = 0; i < len; i++) {
       for (uint256 j = i + 1; j < len; j++) {
           int256 votesI = int256(allEndorsers[i].upVotes) - int256(allEndorsers[i].downVotes);
           int256 votesJ = int256(allEndorsers[j].upVotes) - int256(allEndorsers[j].downVotes);
           if (votesI < votesJ) {
               EndorserApplicant memory temp = allEndorsers[i];
               allEndorsers[i] = allEndorsers[j];
               allEndorsers[j] = temp;
           }
       }
   }
   ```

4. **Returning Data**: Finally, the function returns the sorted arrays.
   ```solidity
   return (allEndorsers, addresses);
   ```

### `calculateVotingPower()`
```solidity
function calculateVotingPower(address voter) public view virtual returns (uint256)
```
This abstract function is used to calculate the voting power of a voter. The implementation is expected in derived contracts.

#### Parameters
- **voter**: The address of the voter for whom the voting power is being calculated.

#### Logic and Explanation
- Since this function is marked as `abstract`, it does not have an implementation in this contract. Derived contracts are required to provide the logic for calculating voting power.

## Usage Example
1. **Register as an Endorser**: Users can call `becomeEndorser()` with their details to register themselves as an endorser.
2. **Vote on an Endorser**: Users can call `voteOnEndorser()` to either upvote or downvote a registered endorser.
3. **Retrieve All Endorsers**: Anyone can call `getAllEndorsers()` to get a list of all endorsers and their details.

## Key Considerations
- **Registration Limit**: Each address can only register once. Attempting to register again will revert with an error message.
- **Voting Restriction**: A user can only vote for one endorser at a time. Voting for multiple endorsers is not allowed.
- **Voting Power**: Voting power is calculated using an abstract function, which means the derived contract must provide the logic for voting power calculation.

## Conclusion
The `Endorser` contract provides a way for users to register as endorsers and for others to vote on them. It maintains a ranked list of endorsers, marking only the top three as active. The voting system uses voting power to determine the influence of each vote, and the ranking is updated each time a vote is cast.

