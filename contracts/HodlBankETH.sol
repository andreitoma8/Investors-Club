// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract HodlBankETH {
    struct User {
        uint256 ethOwned;
        uint256 timeLocked; //in seconds
        uint256 timeOfDeposit;
    }
    address payable public owner;
    uint256 fee; //1 = 0.1%, 1000 = 100%
    mapping(address => User) public users;

    constructor(uint256 _fee) {
        owner = payable(msg.sender);
        fee = _fee;
    }

    function deposit(uint256 _timelocked) public payable {
        require(msg.value > 0, "Amount deposited must be more than 0");
        uint256 _ethOwned = (msg.value * (1000 - fee)) / 1000;
        uint256 _bankFee = (msg.value * fee) / 1000;
        if (users[msg.sender].ethOwned > 0) {
            users[msg.sender].ethOwned = users[msg.sender].ethOwned + _ethOwned;
        } else {
            users[msg.sender] = User(_ethOwned, _timelocked, block.timestamp);
        }
        payable(owner).transfer(_bankFee);
    }

    function withdraw() public {
        User storage user = users[msg.sender];
        require(user.ethOwned > 0, "You have no ETH deposited.");
        require(
            block.timestamp >= (user.timeOfDeposit + user.timeLocked),
            "You tried to withdraw too soon!"
        );
        uint256 withdrawBalance = user.ethOwned;
        user.ethOwned = 0;
        user.timeLocked = 0;
        user.timeOfDeposit = 0;
        payable(msg.sender).transfer(withdrawBalance);
    }

    function getUserInfo(address _userAddress)
        public
        view
        returns (uint256, bool)
    {
        User memory user = users[_userAddress];
        require(user.ethOwned > 0, "This user has no deposit of this token.");
        bool canWithdraw = block.timestamp >=
            (user.timeOfDeposit + user.timeLocked);
        return (user.ethOwned, canWithdraw);
    }

    function bankBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
