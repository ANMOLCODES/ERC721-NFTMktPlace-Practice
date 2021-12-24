const Migrations = artifacts.require("Migrations");
const Market = artifacts.require("Market")
const NFT = artifacts.require("NFT")
module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Market);
  deployer.deploy(NFT);
};
