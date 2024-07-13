<html> 
  <head> 
Information abour User registration smart contract and its component on frontend.
    </head>
<body> 
  <h2> In this readme file you will find all the necessary information about the User Registration smart contract, and its implementation on the frontend as well, along with the linking between the smart contract and the frontend </h2>

<h2> Functionality No 1: Main dashboard component </h2>
<p> 
In the main dashboard page we are getting the actual inv token balance of the user from his metamask wallet, and displaying it on dashboad, as well as we are fetching and displaying the user wallet address as well
</p>  

<h2> Functionality No 2: Profile component  </h2>
  <p> 
 <b> Profile Component : </b> In this component user can enter his/her personal information and it will be stored on blockchaim smart contract, and it will be displaying instantly after submiting the information and can be seen on frontend 
not that for now user can update enterted his information as well. 
</p>

<h2>Functionality No 3:  Assests commponent </h2>
<p> In this component we are getting the user wallet address and fetching the inv tokens balance from his wallet</p>

<h2> User Registration smart contract  </h2>
<p> 
In this smart contract, user can enter his personal information as well as he can change his personal information
</p>

<h2> Ceo Registration.sol  </h2>
<p> In this smart contract ceo can be registered and data will be stored in the smart contract </p>

<h2> Funding Request </h2>
<p> IN this smart contract user submit the funding request, he can submit a nomination form for himself to become an endorser, and than he will be shown in the endorser list, More over in this contract the funding  <br> 
voting functionality is also implemented which is working as the user who is going to vote the endorser must have inv tokens in this wallet, but the vote value is being calculated as: 

 Function Signature: <br> 
  
function voteOnFundingRequest(address requester, bool upVote) public virtual;<br>

Requirements and Preconditions:<br>
The caller must have a balance of at least 1 INV4 token to be eligible to vote:<br>


require(balanceOf(msg.sender) >= 1, "You do not have sufficient INV4 tokens to vote.");<br>
The caller must not have voted on any funding request before:<br>


require(!hasVotedForFundingRequest[msg.sender], "You have already voted on a funding request.");<br>
The caller cannot vote on their own funding request:<br>


require(requester != msg.sender, "You cannot vote on your own funding request.");<br>
Vote Weight Calculation:<br>

The vote weight is calculated based on the balance of the voter, divided by 500:<br>


uint256 voteWeight = balanceOf(msg.sender) / 500;
A minimum vote weight of 1 is required:

require(voteWeight >= 1, "You do not have sufficient voting power to vote.");
Applying the Vote:

If the upVote parameter is true, the upVotes counter and the potentialAmountRaised for the funding request are incremented by the voteWeight:

if (upVote) {
    fundingRequests[requester].upVotes += voteWeight;
    fundingRequests[requester].potentialAmountRaised += voteWeight;
}
If the upVote parameter is false, the downVotes counter is incremented and the potentialAmountRaised is decremented by the voteWeight:

else {
    fundingRequests[requester].downVotes += voteWeight;
    fundingRequests[requester].potentialAmountRaised -= voteWeight;
}
Marking the Voter as Having Voted:

The contract marks the caller as having voted to prevent them from voting again:

hasVotedForFundingRequest[msg.sender] = true;
Emitting the Vote Event:

Finally, the function emits an event to log the voting action:

emit FundingRequestVoted(requester, upVote, msg.sender, voteWeight);
Example Scenario:
Let's consider a voter with an address 0x123... and a balance of 1500 INV4 tokens:

Eligibility Check:

The voter has 1500 INV4 tokens, satisfying the requirement of having at least 1 token.
The voter has not voted before, and they are not voting on their own request.
Vote Weight Calculation:

Vote weight = 1500 / 500 = 3
Applying the Vote:

If upVote is true, the target funding request's upVotes and potentialAmountRaised will be increased by 3.
If upVote is false, the target funding request's downVotes will be increased by 3, and the potentialAmountRaised will be decreased by 3.

</p>

</body>




</html>
