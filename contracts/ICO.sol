// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ICO is Ownable {
    mapping(address => uint256) buyersToAmount;
    AggregatorV3Interface internal ethUsdPriceFeed;
    uint256 valBought = 0;
    uint256 icoSupply = 100000000 * (10**16);
    uint256 maxBuyPerAddress = 1000000 * (10**18);
    uint256 valPrice;
    address public valToken;
    enum ICO_STATE {
        OPEN,
        CLOSED
    }
    ICO_STATE public ico_state;

    constructor(address _valToken, address _priceFeedAddress) {
        valPrice = 1 * (10**16);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        ico_state = ICO_STATE.CLOSED;
        valToken = _valToken;
    }

    function buyValue(uint256 _amount) public payable {
        require(
            ico_state == ICO_STATE.OPEN,
            "The ICO is not open, you can't buy Value now."
        );
        require(
            _amount + buyersToAmount[msg.sender] <= maxBuyPerAddress,
            "You can't buy more than 1000000 per address."
        );
        require(
            (_amount * valPrice) / (10**18) >= getConversionRate(msg.value),
            "You did not pay enough for the amount you want to buy!"
        );
        IERC20(valToken).transferFrom(address(this), msg.sender, _amount);
        buyersToAmount[msg.sender] = buyersToAmount[msg.sender] + _amount;
        if (valBought + _amount > icoSupply) {
            ico_state = ICO_STATE.CLOSED;
        }
        valBought = valBought + _amount;
    }

    function getPrice() internal view returns (uint256) {
        (, int256 answer, , , ) = ethUsdPriceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 _ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function openIco() public onlyOwner {
        ico_state = ICO_STATE.OPEN;
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function viewICOBalance() public view returns (uint256) {
        return (icoSupply - valBought);
    }
}
