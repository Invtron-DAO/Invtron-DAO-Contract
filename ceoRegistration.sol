// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CeoRegistration {
    struct Ceo {
        string firstName;
        string lastName;
        string mobile;
        string postcode;
        string residentAddress;
        string city;
        string state;
        string country;
        string about;
        uint256 createdAt;
    }

    mapping(address => Ceo) public ceos;
    address[] public ceoAddresses;

    event CeoRegistered(
        address indexed ceo,
        string firstName,
        string lastName,
        string mobile,
        string postcode,
        string residentAddress,
        string city,
        string state,
        string country,
        string about
    );

    function becomeCeo(
        string memory _firstName,
        string memory _lastName,
        string memory _mobile,
        string memory _postcode,
        string memory _residentAddress,
        string memory _city,
        string memory _state,
        string memory _country,
        string memory _about
    ) public {
        require(bytes(ceos[msg.sender].firstName).length == 0, "Ceo already registered.");

        ceos[msg.sender] = Ceo({
            firstName: _firstName,
            lastName: _lastName,
            mobile: _mobile,
            postcode: _postcode,
            residentAddress: _residentAddress,
            city: _city,
            state: _state,
            country: _country,
            about: _about,
            createdAt: block.timestamp
        });

        ceoAddresses.push(msg.sender);
        emit CeoRegistered(
            msg.sender,
            _firstName,
            _lastName,
            _mobile,
            _postcode,
            _residentAddress,
            _city,
            _state,
            _country,
            _about
        );
    }

    function getAllCeos() public view returns (Ceo[] memory, address[] memory) {
        uint256 len = ceoAddresses.length;
        Ceo[] memory allCeos = new Ceo[](len);
        address[] memory addresses = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            allCeos[i] = ceos[ceoAddresses[i]];
            addresses[i] = ceoAddresses[i];
        }

        return (allCeos, addresses);
    }

    function getCeos() public view returns (Ceo[] memory, address[] memory) {
        return getAllCeos();
    }
}
