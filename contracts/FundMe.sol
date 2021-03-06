// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
  using SafeMathChainlink for uint256;
  mapping(address => uint256) public addressToAmountFunded;
  address public owner;
  address[] public funders;

  constructor() public {
    owner = msg.sender;
  }

  // payable:
  /*
    Test Funding transaction
    0.1 ETHER is 100000000000000000 WEI
  */
  function fund() public payable {
    // setting a minimum payable to 50 USD
    uint256 minimumUSD = 50 * 10 * 18;

    // check if 1gwei < $50
    require(getConversionRate(msg.value) >= minimumUSD, "You need to spenf more ETH!");

    addressToAmountFunded[msg.sender] += msg.value;
    funders.push(msg.sender);
  }

  function getVersion() public view returns (uint256) {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    return priceFeed.version();
  }

  function getPrice() public view returns (uint256) {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    (,int256 answer,,,) = priceFeed.latestRoundData();
    return uint256(answer);
    // 3,017.44772435 ETH to USD
  }

  // 1000000000 = 1 Gwei 
  function getConversionRate(uint256 ethAmount) public view returns (uint256) {
    uint256 ethPrice = getPrice();
    uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
    return ethAmountInUsd; // 302.811000000000000000
  }

  modifier onlyOwner {
    // check for the admin/owner before perfoming an action
    require(msg.sender == owner);
    _;
  }

  function withdraw() payable onlyOwner public {
    msg.sender.transfer(address(this).balance );

    // iterate over the funders
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      addressToAmountFunded[funder] = 0;
    }
    funders = new address[](0); // reset the funders array
  }
}
