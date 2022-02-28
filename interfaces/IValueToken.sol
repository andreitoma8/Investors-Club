// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IValueToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function stake(uint256 _amount) external;

    function withdrawStake(uint256 amount, uint256 stake_index) external;

    function withdrawRewards(uint256 stake_index) external;

    function newCharityFee(uint256 _newCharityFee) external;

    function newCharity(address _newCharityAddress) external;

    function donate() external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
