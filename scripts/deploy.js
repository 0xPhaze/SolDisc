const { ethers } = require("hardhat");

async function main() {
  const SolDisc = await ethers.getContractFactory("SolDisc");
  const soldisc = await SolDisc.deploy();

  await soldisc.deployed();

  console.log("SolDisc deployed to:", soldisc.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
