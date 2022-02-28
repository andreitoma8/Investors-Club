// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Stakable.sol";

contract ValueToken is ERC20, Ownable, Stakeable {
    address public voteContract;

    modifier onlyVote() {
        require(msg.sender == voteContract);
        _;
    }

    constructor() ERC20("Value", "VAL") {
        _mint(msg.sender, 1000000 * 10**decimals()); //For ICO
    }

    function stake(uint256 _amount) public {
        require(
            _amount < balanceOf(msg.sender),
            "DevToken: Cannot stake more than you own"
        );
        _stake(_amount);
        _burn(msg.sender, _amount);
    }

    function withdrawStake(uint256 amount, uint256 stake_index) public {
        uint256 amount_to_mint = _withdrawStake(amount, stake_index);
        _mint(msg.sender, amount_to_mint);
    }

    function withdrawRewards(uint256 stake_index) public {
        uint256 amount_to_mint = _withdrawStake(0, stake_index);
        _mint(msg.sender, amount_to_mint);
    }

    // onlyVote functions

    function newCharity(address _newCharityAddress) public onlyVote {
        charityAddress = _newCharityAddress;
    }

    // Add gouvernance modifier to this function
    function newCharityFee(uint256 _newCharityFee) public onlyVote {
        charityDonationFee = _newCharityFee;
    }

    // onlyOwner functions

    function donate() public onlyOwner {
        _mint(charityAddress, charityDonationBalance);
        charityDonationBalance = 0;
    }

    function setVotingContract(address _votingContract) public onlyOwner {
        voteContract = _votingContract;
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20) {
        super._burn(account, amount);
    }
}
