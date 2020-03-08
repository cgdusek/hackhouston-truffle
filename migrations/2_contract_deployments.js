const ParxosContract = artifacts.require("./Parxos.sol");
const ParkingContract = artifacts.require("./Parking.sol");
const Web3 = require('web3'); 


module.exports = function(deployer, network, accounts) {
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
    
    const numTokens = 1000;
    const costTokens = 100;
    const costTokensBN = Web3.utils.toWei(costTokens.toString(), 'ether')
    const user1 = accounts[1]
    const owner1 = accounts[2]

    await ParxosContractInstance.transfer(user1, Web3.utils.toWei(numTokens.toString(), 'ether'))
    let balUser1 = await ParxosContractInstance.balanceOf(user1)*10**(-18)
    console.log('Balance of User 1')
    console.log(`${balUser1} PRX`)
    await ParkingContractInstance.addOwner(1, owner1)
    let spaceOwner = await ParkingContractInstance.getSpaceOwner(1)
    console.log('Space Owner Address')
    console.log(spaceOwner)
    await ParkingContractInstance.addOpening(1000, 2000, 0, 0, 1, 1, costTokensBN, {from: owner1})
    await ParxosContractInstance.approve(ParkingContractInstance.address, costTokensBN, {from: user1})
    await ParkingContractInstance.buyOpening(1, {from: user1})
    let balOwner1After = await ParxosContractInstance.balanceOf(owner1)*10**(-18)
    console.log('Balance of Owner 1 after sale')
    console.log(`${balOwner1After} PRX`)
    let balUser1After = await ParxosContractInstance.balanceOf(user1)*10**(-18)
    console.log('Balance of User 1 after sale')
    console.log(`${balUser1After} PRX`) 
  });
}