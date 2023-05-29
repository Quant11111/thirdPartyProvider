import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect } from "chai";

describe("Index Contract", function () {
  let index: any;
  let partners: any;
  let bundles: any;
  let profiles: any;
  let transactions: any;
  let factory: any;
  let owner: Signer;
  let addr1: Signer;

  beforeEach(async function () {
    const Index = await ethers.getContractFactory("Index");
    const Partners = await ethers.getContractFactory("Partners");
    const Bundles = await ethers.getContractFactory("Bundles");
    const Profiles = await ethers.getContractFactory("Profiles");
    const Transactions = await ethers.getContractFactory("Transactions");
    const Factory = await ethers.getContractFactory("Factory");

    [owner, addr1] = await ethers.getSigners();

    index = await Index.connect(owner).deploy();
    await index.deployed();

    partners = await Partners.deploy(index.address);
    await partners.deployed();
    bundles = await Bundles.deploy(index.address);
    await bundles.deployed();
    profiles = await Profiles.deploy(index.address);
    await profiles.deployed();
    transactions = await Transactions.deploy(index.address);
    await transactions.deployed();
    factory = await Factory.deploy(index.address);
    await factory.deployed();
  });

  it("should set addresses correctly", async function () {
    await index.setBundles(bundles.address);
    await index.setFactory(factory.address);
    await index.setPartners(partners.address);
    await index.setProfiles(profiles.address);
    await index.setTransactions(transactions.address);

    expect(await index.bundles()).to.equal(bundles.address);
    expect(await index.factory()).to.equal(factory.address);
    expect(await index.partners()).to.equal(partners.address);
    expect(await index.profiles()).to.equal(profiles.address);
    expect(await index.transactions()).to.equal(transactions.address);
  });
  it("should not be able to set addresses if not owner", async function () {
    await expect(
      index.connect(addr1).setBundles(bundles.address)
    ).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(
      index.connect(addr1).setFactory(factory.address)
    ).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(
      index.connect(addr1).setPartners(partners.address)
    ).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(
      index.connect(addr1).setProfiles(profiles.address)
    ).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(
      index.connect(addr1).setTransactions(transactions.address)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });
});
