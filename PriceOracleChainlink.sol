pragma solidity ^0.5.16;

import "./PriceOracle.sol";
import "./CErc20.sol";
import "./AggregatorV3Interface.sol";

contract PriceOracleChainlink is PriceOracle {
    address public admin;
    // key is the cToken address, value is the priceFeed address
    mapping(address => address) priceFeeds;

    event NewPriceFeed(address cToken, address oldPriceFeed, address newPriceFeed);

    constructor() public {
        admin = msg.sender;
    }

    function setPriceFeed(CToken cToken, AggregatorV3Interface priceFeed) public {
        require(msg.sender == admin, "Only admin can set price feed");
        address oldPriceFeed = priceFeeds[address(cToken)];
        priceFeeds[address(cToken)] = address(priceFeed);
        emit NewPriceFeed(address(cToken), oldPriceFeed, address(priceFeed));
    }

    function getUnderlyingPrice(CToken cToken) public view returns (uint) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeeds[address(cToken)]);
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint(price);
    }

}
