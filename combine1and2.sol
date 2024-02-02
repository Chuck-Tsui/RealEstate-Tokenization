// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateToken is ERC20, Ownable (msg.sender) {
    mapping(uint256 => RealEstate) public realEstates;

    struct RealEstate {
        string name;
        string location;
        uint256 price;
        bool isForSale;
        bool isRedeemed;
        address currentOwner;
    }

    event RealEstateCreated(uint256 indexed realEstateId, string name, string location, uint256 price);
    event RealEstateTransferred(uint256 indexed realEstateId, address from, address to);
    event RealEstateBought(uint256 indexed realEstateId, address buyer);
    event RealEstateRedeemed(uint256 indexed realEstateId, address redeemer);
    event DividendsDistributed(uint256 indexed realEstateId, address receiver, uint256 amount);

    constructor() ERC20("RealEstateToken", "RET") {}

    modifier onlyRealEstateOwner(uint256 realEstateId) {
        require(realEstates[realEstateId].currentOwner == msg.sender, "Not the real estate owner");
        _;
    }

    function createRealEstate(string memory name, string memory location, uint256 price) external onlyOwner {
        uint256 realEstateId = totalSupply() + 1;
        realEstates[realEstateId] = RealEstate(name, location, price, false, false, owner());
        _mint(owner(), 1); // Mint a token representing ownership of the real estate
        emit RealEstateCreated(realEstateId, name, location, price);
    }

    function transferRealEstate(uint256 realEstateId, address to) external onlyRealEstateOwner(realEstateId) {
        realEstates[realEstateId].currentOwner = to;
        emit RealEstateTransferred(realEstateId, msg.sender, to);
    }

    function buyRealEstate(uint256 realEstateId) external payable {
        RealEstate storage realEstate = realEstates[realEstateId];
        require(realEstate.isForSale, "Real estate not for sale");
        require(msg.value >= realEstate.price, "Insufficient funds");

        // Transfer ownership
        address previousOwner = realEstate.currentOwner;
        realEstate.currentOwner = msg.sender;
        realEstate.isForSale = false;

        // Transfer ERC20 ownership
        _transfer(previousOwner, msg.sender, 1);

        // Distribute dividends to previous owner
        uint256 dividends = msg.value - realEstate.price;
        payable(previousOwner).transfer(dividends);
        emit DividendsDistributed(realEstateId, previousOwner, dividends);

        // Emit event
        emit RealEstateBought(realEstateId, msg.sender);
    }

    function redeemRealEstate(uint256 realEstateId) external onlyRealEstateOwner(realEstateId) {
        RealEstate storage realEstate = realEstates[realEstateId];
        require(!realEstate.isRedeemed, "Real estate already redeemed");

        realEstate.isRedeemed = true;

        // Burn ERC20 token representing ownership
        _burn(msg.sender, 1);

        // Transfer funds to the redeemer
        uint256 redemptionAmount = realEstate.price;
        payable(msg.sender).transfer(redemptionAmount);

        emit RealEstateRedeemed(realEstateId, msg.sender);
    }

}
