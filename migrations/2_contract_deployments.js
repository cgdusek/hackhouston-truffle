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
    
    const user1 = {
      address: '0x8741EB1FCf412c29d2C92a6cc4A9E9a1B93dD5c0',
      privKey: '0x06b8717e798f8ceb930b518fa0e7135d4018e256689545fd3ceb6aefe7d63b64'
    }

    const user2 = {
      address: '0xf0Bc96252EF9C4e99281618F7d42ebB0644D0CcA',
      privKey: '0x224a822b14bb9ad1dcf7df5766300a63c6853a85d38e13b8948970fc84a3e9de'
    }

    ParxosContractInstance.transfer(user1.address, 1000*10**18) // May need to BN versus large integer
    ParxosContractInstance.transfer(user2.address, 1000*10**18)
  });
};