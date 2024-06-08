// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Endorser {
    struct EndorserApplicant {
        string firstName;
        string lastName;
        string mobile;
        string postcode;
        string addressDetails;
        string country;
        string bio;
        uint256 upVotes;
        uint256 downVotes;
        bool active;
        uint256 createdAt;
    }

    mapping(address => EndorserApplicant) public endorserApplicants;
    address[] public endorserAddresses;
    mapping(address => bool) public hasVotedForEndorser;

    event EndorserApplicantRegistered(address applicant, string firstName, string lastName);
    event EndorserVoted(address endorser, bool upVote, address voter, uint256 voteWeight);

    function becomeEndorser(
        string memory _firstName,
        string memory _lastName,
        string memory _mobile,
        string memory _postcode,
        string memory _address,
        string memory _country,
        string memory _bio
    ) public {
        require(bytes(endorserApplicants[msg.sender].firstName).length == 0, "Endorser already registered.");
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

        endorserAddresses.push(msg.sender);
        emit EndorserApplicantRegistered(msg.sender, _firstName, _lastName);
    }

    function voteOnEndorser(address endorser, bool upVote) public virtual {
        require(bytes(endorserApplicants[endorser].firstName).length != 0, "Not a registered endorser.");
        require(!hasVotedForEndorser[msg.sender], "You can only vote on one endorser at a time.");
        require(endorser != msg.sender, "You cannot vote on your own endorser request.");

        uint256 voteWeight = calculateVotingPower(msg.sender);
        require(voteWeight >= 1, "You do not have sufficient voting power to vote.");

        if (upVote) {
            endorserApplicants[endorser].upVotes += voteWeight;
        } else {
            endorserApplicants[endorser].downVotes += voteWeight;
        }

        hasVotedForEndorser[msg.sender] = true;
        emit EndorserVoted(endorser, upVote, msg.sender, voteWeight);

        updateEndorserStatus();
    }

    function updateEndorserStatus() internal {
        uint256 len = endorserAddresses.length;
        if (len == 0) return;

        EndorserApplicant[] memory endorsers = new EndorserApplicant[](len);
        address[] memory addresses = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            address addr = endorserAddresses[i];
            endorsers[i] = endorserApplicants[addr];
            addresses[i] = addr;
        }

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

        for (uint256 i = 0; i < len; i++) {
            endorserAddresses[i] = addresses[i];
        }

        for (uint256 i = 0; i < len; i++) {
            address addr = endorserAddresses[i];
            endorserApplicants[addr].active = i < 3;
        }
    }

    function getAllEndorsers() public view returns (EndorserApplicant[] memory, address[] memory) {
        uint256 len = endorserAddresses.length;
        EndorserApplicant[] memory allEndorsers = new EndorserApplicant[](len);
        address[] memory addresses = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            allEndorsers[i] = endorserApplicants[endorserAddresses[i]];
            addresses[i] = endorserAddresses[i];
        }

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

        return (allEndorsers, addresses);
    }

    function calculateVotingPower(address voter) public view virtual returns (uint256);
}
