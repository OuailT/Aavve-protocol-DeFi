//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;



// Import interface
// To interact with the functions of the Pool
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
// To get the address of the pool
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";


// POOL_ADDRESS_PROVIDER = "0x0496275d34753A48320CA58103d5220d394FF77F" Sepolia

/*  1- Deploy the contract
    2- Send aWETH to the contract throught MetaMask
    3- Approve the amount of token you want to supply to AVVE approveETH()
    4- Supply liquidity by calling supply()
    5- Check the balance of aToken receive + accrued interest
    6- Withdraw Our Inital deposit + accrued interest and burn aToken

**/

contract SupplyLiquidity {
      IPoolAddressesProvider public immutable ADDRESS_PROVIDER;  
      IPool public immutable Pool;
      address payable owner;
      
      // WETH address (Sepolia):
      address private immutable WETHAddress = 0xD0dF82dE051244f04BfF3A8bB1f62E1cD39eED92;

      IERC20 public WETH;

      constructor(address _address_Provider) {
        ADDRESS_PROVIDER = IPoolAddressesProvider(_address_Provider);
        Pool = IPool(ADDRESS_PROVIDER.getPool()); 
        WETH = IERC20(WETHAddress);
        owner = payable(msg.sender);
      }


      // @notice supply
      function supplyLiquidity(address _aseetAddress, uint256 _amount) external {
               address asset = _aseetAddress;
               uint256 amount = _amount;
               address onBehalfOf = address(this); // This contract will receive atokens.
               uint16 referralCode = 0;

               Pool.supply(asset, amount, onBehalfOf, referralCode);
      }

    
      // @notice withdraw
      function withdrawLiquidity(address _assetAddress, uint256 _amount) external returns (uint256) {
               address to = address(this);
               return Pool.withdraw(_assetAddress, _amount, to);
      }
      

      // @notice getUserAccountData
      function getUserAccountData(address _userAddress) external view returns (
                uint256 totalCollateralBase,
                uint256 totalDebtBase,
                uint256 availableBorrowsBase,
                uint256 currentLiquidationThreshold,
                uint256 ltv,
                uint256 healthFactor
    ) {
            return Pool.getUserAccountData(_userAddress);
      }


      // Approve ETH
      function approveETH (uint256 _amount, address _poolContractAddress) external returns (bool) {
          return WETH.approve(_poolContractAddress, _amount);
      }

      function allowanceETH(address _poolContractAddress) external view returns(uint256) {
            return WETH.allowance(address(this), _poolContractAddress);
      }


      function getBalance(address _tokenAddress) external view returns(uint256) {
            return IERC20(_tokenAddress).balanceOf(address(this));
      }


      function withdraw(address _tokenAddress) external onlyOwner {
            IERC20 token = IERC20(_tokenAddress);
            uint256 Balance = token.balanceOf(address(this));
            token.transfer(msg.sender, Balance);
      }

      modifier onlyOwner() {
            require(owner == msg.sender, "unauthorized called");
            _;
      }

      receive() external payable {}

}


