# Invtron-DAO-Contract
This repository contains the smart contracts for Invtron DAO, a revolutionary platform leveraging blockchain technology to democratize startup funding. Our contracts ensure transparent, secure, and efficient decentralized investment processes, empowering a global network of investors to support innovative projects.Lets have a look how it works.

The Invtron DAO smart contracts are designed to facilitate a decentralized, transparent, and secure investment platform. Here's a detailed explanation of each contract and its functionality:

1. Main Invtron Contract (Main invtron contract.sol)
This is the core contract of the Invtron DAO platform. It includes the main functionalities and interactions for managing the DAO's operations, such as handling investments, token management, and overall governance.

2. CEO Registration Contract (ceoRegistration.sol)
This contract handles the registration and management of the CEO within the Invtron DAO ecosystem. Key features include:

Struct Ceo: Defines the attributes of a CEO, including personal details and a timestamp for when they were registered.
Mapping ceos: Stores CEO details with their Ethereum address as the key.
Array ceoAddresses: Keeps a list of all registered CEO addresses.
Events: CeoRegistered to log when a new CEO is registered.
Functions:
becomeCeo: Allows a user to register as a CEO, provided they have not already registered.
getAllCeos: Returns all registered CEOs and their addresses.
3. Endorser Contract (endorser.sol)
This contract manages the endorsers who play a critical role in the Proof of Due Diligence (PoDD) process. Key functionalities include:

Struct Endorser: Defines the attributes of an endorser, such as their personal details and registration time.
Mapping endorsers: Stores endorser details using their Ethereum address as the key.
Array endorserAddresses: Keeps a list of all registered endorser addresses.
Events: EndorserRegistered to log when a new endorser registers.
Functions:
becomeEndorser: Allows a user to register as an endorser.
getAllEndorsers: Returns all registered endorsers and their addresses.
4. Funding Request Contract (fundingRequest.sol)
This contract likely manages the funding requests submitted by startups or projects seeking investment. Specific details were not fully visible, but it generally includes:

Struct FundingRequest: Defines the attributes of a funding request, such as the project details, requested amount, and submission time.
Functions:
createFundingRequest: Allows a project to submit a new funding request.
voteOnFundingRequest: Allows token holders to vote on funding requests as part of the PoDD mechanism.
getAllFundingRequests: Returns all submitted funding requests.
5. User Registration Contract (userRegistration.sol)
This contract handles the registration and management of general users on the Invtron DAO platform. Key features include:

Struct User: Defines user attributes, including personal details and interests.
Mapping users: Stores user details with their Ethereum address as the key.
Array userAddresses: Maintains a list of all registered user addresses.
Events: UserRegistered and UserUpdated to log user registration and updates.
Functions:
registerUser: Allows a new user to register on the platform.
updateUser: Enables users to update their registration details.
getAllUsers: Returns all registered users and their addresses.
Future Updates
From now on, any changes or updates to these smart contracts will be committed to this repository. This ensures transparency and allows the community to track the development and modifications of the platform’s core functionalities.
