# UserRegistration Contract

## Overview
The `UserRegistration` contract is designed to allow users to register themselves, providing personal details, and to update their information whenever required. The contract maintains a list of all registered users and provides functionality to retrieve them.

### Key Features
- Allows users to register themselves by providing personal details.
- Enables users to update their registration information.
- Provides a method to retrieve all registered users and their details.

## Structs and State Variables

### User Struct
- **firstName**: The first name of the user.
- **lastName**: The last name of the user.
- **mobile**: The mobile number of the user.
- **interests**: A string describing the user's interests.
- **paddress**: The permanent address of the user.
- **state**: The state of residence.
- **country**: The country of residence.
- **city**: The city of residence.
- **postcode**: The postal code of the user's address.
- **createdAt**: A timestamp representing the time of registration.

### State Variables
- **mapping(address => User) public users**: Maps an Ethereum address to a `User` struct, storing the details of each registered user.
- **address[] public userAddresses**: An array that keeps track of all registered user addresses.

### Events
- **UserRegistered(address indexed user, string firstName, string lastName)**: Emitted when a new user registers.
- **UserUpdated(address indexed user, string firstName, string lastName)**: Emitted when a registered user updates their information.

## Functions

### `registerUser()`
```solidity
function registerUser(
    string memory _firstName,
    string memory _lastName,
    string memory _mobile,
    string memory _interests,
    string memory _paddress,
    string memory _state,
    string memory _country,
    string memory _city,
    string memory _postcode
) public
```
This function allows a user to register by providing personal information.

#### Parameters
- **_firstName**: The first name of the user.
- **_lastName**: The last name of the user.
- **_mobile**: The mobile number of the user.
- **_interests**: A string describing the user's interests.
- **_paddress**: The permanent address of the user.
- **_state**: The state of residence.
- **_country**: The country of residence.
- **_city**: The city of residence.
- **_postcode**: The postal code of the user's address.

#### Logic and Explanation
1. **Validation Check**: The function first checks if the user is already registered by verifying if their `firstName` is non-empty.
   ```solidity
   require(bytes(users[msg.sender].firstName).length == 0, "User already registered.");
   ```
   - If the user is already registered, the function reverts with an error message.

2. **Storing Data**: If the user is not registered, the function stores the provided information in the `users` mapping by creating a new `User` struct.
   ```solidity
   users[msg.sender] = User({
       firstName: _firstName,
       lastName: _lastName,
       mobile: _mobile,
       interests: _interests,
       paddress: _paddress,
       state: _state,
       country: _country,
       city: _city,
       postcode: _postcode,
       createdAt: block.timestamp
   });
   ```

3. **Tracking Registered Users**: The user's address is added to the `userAddresses` array to keep track of all registered users.
   ```solidity
   userAddresses.push(msg.sender);
   ```

4. **Event Emission**: Finally, the function emits the `UserRegistered` event.
   ```solidity
   emit UserRegistered(msg.sender, _firstName, _lastName);
   ```

### `updateUser()`
```solidity
function updateUser(
    string memory _firstName,
    string memory _lastName,
    string memory _mobile,
    string memory _interests,
    string memory _paddress,
    string memory _state,
    string memory _country,
    string memory _city,
    string memory _postcode
) public
```
This function allows a registered user to update their personal information.

#### Parameters
- **_firstName**: The updated first name of the user.
- **_lastName**: The updated last name of the user.
- **_mobile**: The updated mobile number of the user.
- **_interests**: The updated interests of the user.
- **_paddress**: The updated permanent address of the user.
- **_state**: The updated state of residence.
- **_country**: The updated country of residence.
- **_city**: The updated city of residence.
- **_postcode**: The updated postal code of the user's address.

#### Logic and Explanation
1. **Validation Check**: The function checks if the user is already registered.
   ```solidity
   require(bytes(users[msg.sender].firstName).length != 0, "User not registered.");
   ```
   - If the user is not registered, the function reverts with an error message.

2. **Updating Data**: If the user is registered, the function updates their information in the `users` mapping.
   ```solidity
   users[msg.sender] = User({
       firstName: _firstName,
       lastName: _lastName,
       mobile: _mobile,
       interests: _interests,
       paddress: _paddress,
       state: _state,
       country: _country,
       city: _city,
       postcode: _postcode,
       createdAt: users[msg.sender].createdAt
   });
   ```
   - The `createdAt` value is preserved from the original registration to maintain the original timestamp.

3. **Event Emission**: The function emits the `UserUpdated` event.
   ```solidity
   emit UserUpdated(msg.sender, _firstName, _lastName);
   ```

### `getAllUsers()`
```solidity
function getAllUsers() public view returns (User[] memory, address[] memory)
```
This function allows anyone to retrieve the list of all registered users and their details.

#### Return Values
- **User[] memory**: An array containing all registered users and their details.
- **address[] memory**: An array of addresses corresponding to the registered users.

#### Logic and Explanation
1. **Array Creation**: The function creates arrays to hold all users and their addresses.
   ```solidity
   User[] memory allUsers = new User[](len);
   address[] memory addresses = new address[](len);
   ```

2. **Populating Arrays**: The function populates the arrays with the details of all registered users.
   ```solidity
   for (uint256 i = 0; i < len; i++) {
       allUsers[i] = users[userAddresses[i]];
       addresses[i] = userAddresses[i];
   }
   ```

3. **Returning Data**: Finally, the function returns the populated arrays.
   ```solidity
   return (allUsers, addresses);
   ```

## Usage Example
1. **Register as a User**: Users can call `registerUser()` with their details to register themselves on the platform.
2. **Update User Information**: Registered users can call `updateUser()` to update their personal information.
3. **Retrieve All Users**: Anyone can call `getAllUsers()` to get a list of all registered users and their details.

## Key Considerations
- **Registration Restriction**: Each address can only register once. Attempting to register again will revert with an error message.
- **Updating Details**: Only registered users can update their details. If a user is not registered, attempting to update information will revert with an error.

## Conclusion
The `UserRegistration` contract allows users to register and update their personal information, while maintaining a record of all registered users. It provides an easy way to manage user data and ensures that only registered users can update their information. The contract can be used in various decentralized applications where user registration and data management are required.

