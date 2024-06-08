// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.6.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.6.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.6.0/contracts/security/ReentrancyGuard.sol";
import "./Endorser.sol";
import "./FundingRequest.sol";
import "./UserRegistration.sol";
import "./CeoRegistration.sol";  // Importing the CeoRegistration contract

/**
 * @title Invtron4 Smart Contract
 * @dev Extends ERC20 token functionality with voting mechanisms, CEO application process, funding request creation, and user registration.
 */
contract Invtron4 is ERC20, Ownable, ReentrancyGuard, Endorser, FundingRequest, UserRegistration, CeoRegistration {
    uint256 public constant VOTE_DURATION = 72 hours;
    uint256 public constant VOTE_PERCENTAGE = 3;
    uint256 public constant VOTE_LOOKBACK_PERIOD = 10 minutes;

    struct Transaction {
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => Transaction[]) public outgoingTransactions;
    mapping(address => uint256) public initialBalances;

    event ApplicantRegistered(address applicant, string firstName, string lastName);

    constructor() ERC20("Invtron4", "INV4") {
        uint256 totalSupply = 1_000_000_000 * (10**uint256(decimals()));
        _mint(msg.sender, totalSupply);
        uint256 reserveForContract = totalSupply / 10;
        _transfer(msg.sender, address(this), reserveForContract);
    }

    function calculateVotingPower(address voter) public view override returns (uint256) {
        uint256 totalOutgoingTokens = getOutgoingTokens(voter, VOTE_LOOKBACK_PERIOD);
        uint256 initialBalance = initialBalances[voter];
        return initialBalance - totalOutgoingTokens;
    }

    function getOutgoingTokens(address voter, uint256 lookbackPeriod) public view returns (uint256) {
        uint256 outgoingTokens = 0;
        uint256 currentTime = block.timestamp;
        Transaction[] storage transactions = outgoingTransactions[voter];

        for (uint256 i = transactions.length; i > 0; i--) {
            if (transactions[i - 1].timestamp + lookbackPeriod < currentTime) {
                break;
            }
            outgoingTokens += transactions[i - 1].amount;
        }

        return outgoingTokens;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        super._transfer(sender, recipient, amount);

        outgoingTransactions[sender].push(Transaction({
            timestamp: block.timestamp,
            amount: amount
        }));

        cleanOldTransactions(sender);

        if (initialBalances[sender] == 0) {
            initialBalances[sender] = balanceOf(sender) + amount;
        }
    }

    function cleanOldTransactions(address sender) internal {
        uint256 currentTime = block.timestamp;
        Transaction[] storage transactions = outgoingTransactions[sender];

        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].timestamp + VOTE_LOOKBACK_PERIOD < currentTime) {
                transactions[i] = transactions[transactions.length - 1];
                transactions.pop();
                i--;
            }
        }
    }

    function getRemainingVoteTime(address requestAddress, bool isFundingRequest) public view returns (uint256) {
        if (isFundingRequest) {
            FundingRequestStruct storage request = fundingRequests[requestAddress];
            if (request.createdAt == 0) {
                return 0;
            }
            uint256 endTime = request.createdAt + VOTE_DURATION;
            if (block.timestamp >= endTime) {
                return 0;
            }
            return endTime - block.timestamp;
        } else {
            EndorserApplicant storage endorser = endorserApplicants[requestAddress];
            if (endorser.createdAt == 0) {
                return 0;
            }
            uint256 endTime = endorser.createdAt + VOTE_DURATION;
            if (block.timestamp >= endTime) {
                return 0;
            }
            return endTime - block.timestamp;
        }
    }

    // Override the balanceOf function from the abstract FundingRequest and ERC20 contracts
    function balanceOf(address account) public view override(ERC20, FundingRequest) returns (uint256) {
        return super.balanceOf(account);
    }
}
