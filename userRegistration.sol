// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract UserRegistration {
    struct User {
        string firstName;
        string lastName;
        string mobile;
        string interests;
        string paddress;
        string state;
        string country;
        string city;
        string postcode;
        uint256 createdAt;
    }

    mapping(address => User) public users;
    address[] public userAddresses;

    event UserRegistered(address indexed user, string firstName, string lastName);
    event UserUpdated(address indexed user, string firstName, string lastName);

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
    ) public {
        require(bytes(users[msg.sender].firstName).length == 0, "User already registered.");
        
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

        userAddresses.push(msg.sender);
        emit UserRegistered(msg.sender, _firstName, _lastName);
    }

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
    ) public {
        require(bytes(users[msg.sender].firstName).length != 0, "User not registered.");

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

        emit UserUpdated(msg.sender, _firstName, _lastName);
    }

    function getAllUsers() public view returns (User[] memory, address[] memory) {
        uint256 len = userAddresses.length;
        User[] memory allUsers = new User[](len);
        address[] memory addresses = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            allUsers[i] = users[userAddresses[i]];
            addresses[i] = userAddresses[i];
        }

        return (allUsers, addresses);
    }
}
