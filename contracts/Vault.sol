// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ERC4626 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Vault {
    ERC4626 public tokenA;
    uint256 public rewardPerBlock = 1; // 1 token per block
    uint256 public lastBlock = block.number;
    uint256 public totalReward = 0;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public rewardOf;
    
    constructor(address _tokenA) {
        tokenA = ERC4626(_tokenA);
    }

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     * @param amount of AToken, deposited in Vault.
     */
    function deposit(uint256 amount) external {
        uint256 balanceBefore = tokenA.balanceOf(address(this));
        require(tokenA.transferFrom(msg.sender, address(this), amount), "transfer failed");
        uint256 balanceAfter = tokenA.balanceOf(address(this));
        uint256 delta = balanceAfter - balanceBefore;
        uint256 vaultTokens = delta * 100 / 1000; // X or 2X depending on the user
        balanceOf[msg.sender] += vaultTokens;
    }
    
    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     * @param amount of AToken, withdrawn from Vault.
     */
    function withdraw(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "not enough balance");
        uint256 reward = calculateReward(msg.sender);
        balanceOf[msg.sender] -= amount;
        rewardOf[msg.sender] += reward;
        totalReward -= reward;
        require(tokenA.transfer(msg.sender, amount), "transfer failed");
    }
    
    /**
     * @dev Calculates the amount of earned by a user since their last update based on the elapsed time and their vault balance.
     * @param account address of which reward will be calculated.
     */
    function calculateReward(address account) internal view returns (uint256) {
        uint256 blocksPassed = block.number - lastBlock;
        uint256 reward = balanceOf[account] * rewardPerBlock * blocksPassed;
        return reward;
    }
    
    /**
     * @dev Allows the owner of the contract to update the rewardPerBlock variable.
     */
    function updateReward() external {
        uint256 blocksPassed = block.number - lastBlock;
        uint256 reward = 1000 * rewardPerBlock * blocksPassed;
        totalReward += reward;
        rewardPerBlock = totalReward / 100; // distribute 100 reward tokens per 100 blocks
        lastBlock = block.number;
    }
}