// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IValueToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    struct Voter {
        bool voted;
        uint256 vote;
    }

    struct Proposal {
        address charity;
        uint256 voteCount;
    }

    address public chairperson;
    IValueToken internal valToken;

    mapping(uint256 => mapping(address => Voter)) public voters;

    Proposal[] public proposals;

    uint256 proposalsIndex;
    uint256 minAmount = 10000; //balance of tokens/voter

    enum VOTING_STATE {
        OPEN,
        CLOSED
    }
    VOTING_STATE public voting_state;

    constructor(address _valTokenAddress) {
        voting_state = VOTING_STATE.CLOSED;
        valToken = IValueToken(_valTokenAddress);
    }

    function createProposal(address[] memory proposalAddresses)
        public
        onlyOwner
    {
        if (proposals.length >= 1) {
            delete proposals;
        }
        for (uint256 i = 0; i < proposalAddresses.length; i++) {
            proposals.push(
                Proposal({charity: proposalAddresses[i], voteCount: 0})
            );
        }
    }

    function startVoting() public onlyOwner {
        voting_state = VOTING_STATE.OPEN;
    }

    function vote(uint256 proposal) public {
        require(voting_state == VOTING_STATE.OPEN);
        Voter storage sender = voters[proposalsIndex][msg.sender];
        require(
            valToken.balanceOf(msg.sender) > minAmount * (10**18),
            "You don't have enough VAL to vote."
        );
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount++;
    }

    function winningProposal() internal returns (uint256 winner) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winner = p;
            }
        }
        valToken.newCharity(proposals[winner].charity);
        proposalsIndex++;
        voting_state = VOTING_STATE.CLOSED;
    }

    function winnerAddress() public onlyOwner returns (address winner) {
        winner = proposals[winningProposal()].charity;
    }
}
