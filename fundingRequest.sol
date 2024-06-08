// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract FundingRequest {
    struct FundingRequestStruct {
        string projectName;
        uint256 softCap;
        uint256 requiredAmount;
        string shortDescription;
        string country;
        string websiteURL;
        string ceoLinkedinURL;
        string companyRegistrationURL;
        uint256 upVotes;
        uint256 downVotes;
        uint256 potentialAmountRaised;
        uint256 createdAt;
    }

    mapping(address => FundingRequestStruct) public fundingRequests;
    address[] public fundingRequestAddresses;
    mapping(address => bool) public activeRequests;
    mapping(address => bool) public hasVotedForFundingRequest;

    event FundingRequestCreated(address requester, string projectName);
    event FundingRequestVoted(address requester, bool upVote, address voter, uint256 voteWeight);

    function createFundingRequest(
        string memory _projectName,
        uint256 _softCap,
        uint256 _requiredAmount,
        string memory _shortDescription,
        string memory _country,
        string memory _websiteURL,
        string memory _ceoLinkedinURL,
        string memory _companyRegistrationURL
    ) public {
        require(!activeRequests[msg.sender], "Funding request already created.");
        require(bytes(fundingRequests[msg.sender].projectName).length == 0, "Funding request already created.");

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

        activeRequests[msg.sender] = true;
        fundingRequestAddresses.push(msg.sender);
        emit FundingRequestCreated(msg.sender, _projectName);
    }

    function voteOnFundingRequest(address requester, bool upVote) public virtual {
        require(balanceOf(msg.sender) >= 1, "You do not have sufficient INV4 tokens to vote.");
        require(!hasVotedForFundingRequest[msg.sender], "You have already voted on a funding request.");
        require(requester != msg.sender, "You cannot vote on your own funding request.");

        uint256 voteWeight = balanceOf(msg.sender) / 500;
        require(voteWeight >= 1, "You do not have sufficient voting power to vote.");

        if (upVote) {
            fundingRequests[requester].upVotes += voteWeight;
            fundingRequests[requester].potentialAmountRaised += voteWeight;
        } else {
            fundingRequests[requester].downVotes += voteWeight;
            fundingRequests[requester].potentialAmountRaised -= voteWeight;
        }

        hasVotedForFundingRequest[msg.sender] = true;
        emit FundingRequestVoted(requester, upVote, msg.sender, voteWeight);
    }

    function getAllFundingRequests() public view returns (FundingRequestStruct[] memory, address[] memory) {
        uint256 len = fundingRequestAddresses.length;
        FundingRequestStruct[] memory allFundingRequests = new FundingRequestStruct[](len);
        address[] memory addresses = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            allFundingRequests[i] = fundingRequests[fundingRequestAddresses[i]];
            addresses[i] = fundingRequestAddresses[i];
        }

        return (allFundingRequests, addresses);
    }

    function balanceOf(address account) public view virtual returns (uint256);
}
