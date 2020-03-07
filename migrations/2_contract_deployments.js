const ParxosContract = artifacts.require("./Parxos.sol");
const ParkingContract = artifacts.require("./Parking.sol");


module.exports = function(deployer) {
  deployer.then( async() => {
    await deployer.deploy(ParxosContract);
    const ParxosContractInstance = await ParxosContract.deployed()
    console.log('\n*************************************************************************\n')
    console.log(`Parxos Contract Address: ${ParxosContractInstance.address}`)
    console.log('\n*************************************************************************\n')
    await deployer.deploy(
      ParkingContract, 
      ParxosContractInstance.address
    )
    const ParkingContractInstance = await ParkingContract.deployed()
    console.log('\n*************************************************************************\n')
    console.log(`Parking Contract Address: ${ParkingContractInstance.address}`)
    console.log('\n*************************************************************************\n')
  });
};