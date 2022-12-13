// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

require('dotenv').config();

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    const deployerAddr = process.env.TEAVAULTV2DEPLOYER || "";
    if (deployerAddr === "") {
        throw "No TEAVAULTV2DEPLOYER";
    }

    const salt = process.env.TEAVAULTV2SALT || "";
    if (salt === "")  {
        throw "No TEAVAULTV2SALT";
    }

    // We get the contract to deploy
    const Deployer = await ethers.getContractFactory("TeaVaultV2Deployer");
    const deployer = Deployer.attach(deployerAddr);

    const newAddr = await deployer.predictedAddress(salt);
    let codes = await ethers.provider.getCode(newAddr);
    if (codes === '0x') {   
        const tx = await deployer.deploy(salt);
        await tx.wait();

        codes = await ethers.provider.getCode(newAddr);
        if (codes === '0x') {
            throw "Contract is not deployed."
        }

        console.log("TeaVaultV2 deployed to:", newAddr);
    }
    else {
        console.log("TeaVaultV2 already deployed to:", newAddr);
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
