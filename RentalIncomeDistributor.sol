pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RentAndDividend is ReentrancyGuard, Ownable {
    IERC20 public propertyToken;

    event RentPaid(address indexed tenant, uint256 amount);
    event DividendsDistributed(uint256 totalAmount);

    constructor(address _propertyTokenAddress) {
        propertyToken = IERC20(_propertyTokenAddress);
    }

    // 租客支付房租
    function payRent() external payable {
        emit RentPaid(msg.sender, msg.value);
    }

    // 分红执行
    function distributeDividends() external onlyOwner nonReentrant {
        uint256 totalRent = address(this).balance;
        require(totalRent > 0, "No rent to distribute");

        uint256 totalSupply = propertyToken.totalSupply();
        require(totalSupply > 0, "Total supply cannot be 0");

        for (uint256 i = 0; i < totalSupply; i++) {
            // 这里需要一种方法来遍历或直接获取代币持有者和他们的余额
            // 注意：实际实现中，这可能需要考虑合约的性能和成本，特别是如果持有者数量很大的话
        }

        emit DividendsDistributed(totalRent);
    }

    // 提供一个函数来允许合约拥有者提取合约中累积的ETH，作为额外的安全措施
    function withdraw(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    // 其他必要的辅助函数和逻辑
}
