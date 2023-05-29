import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect } from "chai";

describe("Index Contract", function () {
  let index: any;
  let owner: Signer;
  let addr1: Signer;

  beforeEach(async function () {
    const Index = await ethers.getContractFactory("Index");
    [owner, addr1] = await ethers.getSigners();

    index = await Index.deploy();
    await index.deployed();
  });

  it("should set addresses correctly", async function () {
    const addr2 = await addr1.getAddress();

    await index.setBundles(addr2);
    await index.setFactory(addr2);
    await index.setPartners(addr2);
    await index.setProfiles(addr2);
    await index.setTransactions(addr2);

    expect(await index.bundles()).to.equal(addr2);
    expect(await index.factory()).to.equal(addr2);
    expect(await index.partners()).to.equal(addr2);
    expect(await index.profiles()).to.equal(addr2);
    expect(await index.transactions()).to.equal(addr2);
  });
  it("should revert if not called by owner", async function () {
    const addr2 = await addr1.getAddress();
    await index.connect(addr1).setBundles(addr2);
    expect(index.connect(addr1).setBundles(addr2)).to.be.revertedWith(
      "Ownable: caller is not the owner"
    );
  });
});
