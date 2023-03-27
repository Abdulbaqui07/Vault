const hre = require("hardhat");

async function main() {
    // Setting up the deploying parameters
    const [deployer] = await hre.ethers.getSigners();
    const contractName = "Vault";

    // Deploying the contract
    console.log(`Deploying ${contractName}...`);
    const Contract = await hre.ethers.getContractFactory("Vault");
    const contract = await Contract.deploy();
    await contract.deployed("AToken");
    console.log(`${contractName} deployed to: ${contract.address}`);

    process.exit(0);
}

main()
    .then(() => { })
    .catch((error) => {
        console.log(error);
        process.exit(1);
    });