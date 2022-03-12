const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log('Contract deployed to:', nftContract.address);

  // Create 7 NFTs.
  for (let i = 0; i < 6; i++) {
    try {
      let txn = await nftContract.makeAnEpicNFT();
      await txn.wait();
    } catch (error) {
      console.log(error);
    }
  }
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

// Run the deploy 6 times to mint 6 NFTs.
runMain();
