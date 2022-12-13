import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
    TeaVaultV2,
    MockERC20,
    MockERC721,
    FilterMapper,
    ERC20Filter,
    BaseFilter,
} from "../typechain-types";

const parseEther = ethers.utils.parseEther;

describe("TeaVaultV2", function () {

    let admin: SignerWithAddress; // owner address
    let investor: SignerWithAddress; // investor address
    let manager: SignerWithAddress; // manager address
    let addr1: SignerWithAddress; // dummy address 1
    let addr2: SignerWithAddress; // dummy address 2

    let teavault: TeaVaultV2;
    let erc20: MockERC20;
    let filterMapper: FilterMapper;
    let erc20Filter: ERC20Filter;
    let dummy: BaseFilter;

    beforeEach(async function() {
        [admin, investor, manager, addr1, addr2] = await ethers.getSigners();

        // deploy
        const MockERC20 = await ethers.getContractFactory("MockERC20");
        erc20 = await MockERC20.deploy(parseEther("20000000"));

        let tx = await erc20.transfer(investor.address, parseEther("10000"));
        await tx.wait();

        tx = await erc20.transfer(addr1.address, parseEther("10000"));
        await tx.wait();

        const TeaVaultV2 = await ethers.getContractFactory("TeaVaultV2");
        teavault = await TeaVaultV2.deploy(admin.address);

        const FilterMapper = await ethers.getContractFactory("FilterMapper");
        filterMapper = await FilterMapper.deploy();

        tx = await teavault.assignFilterMapper(filterMapper.address);
        await tx.wait();

        tx = await teavault.assignManager(manager.address);
        await tx.wait();

        tx = await teavault.assignInvestor(investor.address);
        await tx.wait();

        const ERC20Filter = await ethers.getContractFactory("ERC20Filter");
        erc20Filter = await ERC20Filter.deploy();

        tx = await filterMapper.assignFilterMapping(erc20.address, erc20Filter.address);
        await tx.wait();

        // setup a dummy contract
        const BaseFilter = await ethers.getContractFactory("BaseFilter");
        dummy = await BaseFilter.deploy();

        // assign allowed approval
        tx = await erc20Filter.assignAllowedSpender(dummy.address, true);
        await tx.wait();
    });

    it("Test assignFilterMapper", async function() {
        let tx = await teavault.assignFilterMapper(dummy.address);
        await tx.wait();

        let config = await teavault.config();
        expect(config.filterMapper).to.equal(dummy.address);

        await expect(teavault.connect(addr1).assignFilterMapper(filterMapper.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Test assignManager", async function() {
        let tx = await teavault.assignManager(dummy.address);
        await tx.wait();

        let config = await teavault.config();
        expect(config.manager).to.equal(dummy.address);

        await expect(teavault.connect(addr1).assignManager(manager.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });
    
    it("Test assignInvestor", async function() {
        let tx = await teavault.assignInvestor(dummy.address);
        await tx.wait();

        let config = await teavault.config();
        expect(config.investor).to.equal(dummy.address);

        await expect(teavault.connect(addr1).assignInvestor(investor.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Test setAllowManagerSignature", async function() {
        let tx = await teavault.setAllowManagerSignature(true);
        await tx.wait();

        let config = await teavault.config();
        expect(config.allowManagerSignature).to.equal(true);

        await expect(teavault.connect(addr1).setAllowManagerSignature(false)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Deposit and withdraw", async function() {
        const amount = parseEther("100");

        let tx = await erc20.connect(investor).approve(teavault.address, amount);
        await tx.wait();

        tx = await teavault.connect(investor).deposit(erc20.address, amount);
        await tx.wait();

        let balance = await erc20.balanceOf(teavault.address);
        expect(balance).to.equal(amount);

        tx = await teavault.connect(investor).withdraw(investor.address, erc20.address, amount);
        await tx.wait();

        balance = await erc20.balanceOf(teavault.address);
        expect(balance).to.equal("0");
    });

    it("Deposit and withdraw from wrong address", async function() {
        const amount = parseEther("100");

        let tx = await erc20.connect(addr1).approve(teavault.address, amount);
        await tx.wait();

        await expect(teavault.connect(addr1).deposit(erc20.address, amount)).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
        await expect(teavault.connect(addr1).withdraw(addr1.address, erc20.address, amount)).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
    });

    it("Deposit721 and withdraw721", async function() {
        const MockERC721 = await ethers.getContractFactory("MockERC721");
        const erc721 = await MockERC721.deploy();

        let tx = await erc721.connect(investor).mint(investor.address);
        await tx.wait();

        tx = await erc721.connect(investor).approve(teavault.address, 0);
        await tx.wait();

        tx = await teavault.connect(investor).deposit721(erc721.address, 0);
        await tx.wait();

        let balance = await erc721.balanceOf(teavault.address);
        expect(balance).to.equal(1);

        tx = await teavault.connect(investor).withdraw721(investor.address, erc721.address, 0);
        await tx.wait();

        balance = await erc721.balanceOf(teavault.address);
        expect(balance).to.equal(0);
    });

    it("Deposit721 and withdraw721 from wrong address", async function() {
        const MockERC721 = await ethers.getContractFactory("MockERC721");
        const erc721 = await MockERC721.deploy();

        let tx = await erc721.connect(addr1).mint(addr1.address);
        await tx.wait();

        tx = await erc721.connect(addr1).approve(teavault.address, 0);
        await tx.wait();

        await expect(teavault.connect(addr1).deposit721(erc721.address, 0)).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
        await expect(teavault.connect(addr1).withdraw721(addr1.address, erc721.address, 0)).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
    });

    it("Deposit1155 and withdraw1155", async function() {
        const MockERC1155 = await ethers.getContractFactory("MockERC1155");
        const erc1155 = await MockERC1155.connect(investor).deploy();
        const amount = "10000000";

        let tx = await erc1155.connect(investor).setApprovalForAll(teavault.address, true);
        await tx.wait();

        tx = await teavault.connect(investor).deposit1155(erc1155.address, 0, amount);
        await tx.wait();

        let balance = await erc1155.balanceOf(teavault.address, 0);
        expect(balance).to.equal(amount);

        tx = await teavault.connect(investor).withdraw1155(investor.address, erc1155.address, 0, amount);
        await tx.wait();

        balance = await erc1155.balanceOf(teavault.address, 0);
        expect(balance).to.equal(0);
    });

    it("Deposit1155 and withdraw1155 from wrong address", async function() {
        const MockERC1155 = await ethers.getContractFactory("MockERC1155");
        const erc1155 = await MockERC1155.connect(addr1).deploy();
        const amount = "10000000";

        let tx = await erc1155.connect(addr1).setApprovalForAll(teavault.address, true);
        await tx.wait();

        await expect(teavault.connect(addr1).deposit1155(erc1155.address, 0, amount)).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
        await expect(teavault.connect(addr1).withdraw1155(addr1.address, erc1155.address, 0, amount)).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
    });

    it("Deposit1155Batch and withdraw1155Batch", async function() {
        const MockERC1155 = await ethers.getContractFactory("MockERC1155");
        const erc1155 = await MockERC1155.connect(investor).deploy();
        const amount0 = "10000000";
        const amount1 = "100000";

        let tx = await erc1155.connect(investor).setApprovalForAll(teavault.address, true);
        await tx.wait();

        tx = await teavault.connect(investor).deposit1155Batch(erc1155.address, [ 0, 1 ], [ amount0, amount1 ]);
        await tx.wait();

        let balance = await erc1155.balanceOf(teavault.address, 0);
        expect(balance).to.equal(amount0);

        balance = await erc1155.balanceOf(teavault.address, 1);
        expect(balance).to.equal(amount1);

        tx = await teavault.connect(investor).withdraw1155Batch(investor.address, erc1155.address, [ 0, 1 ], [ amount0, amount1 ]);
        await tx.wait();

        balance = await erc1155.balanceOf(teavault.address, 0);
        expect(balance).to.equal(0);

        balance = await erc1155.balanceOf(teavault.address, 1);
        expect(balance).to.equal(0);
    });

    it("Deposit1155 and withdraw1155 from wrong address", async function() {
        const MockERC1155 = await ethers.getContractFactory("MockERC1155");
        const erc1155 = await MockERC1155.connect(addr1).deploy();
        const amount0 = "10000000";
        const amount1 = "100000";

        let tx = await erc1155.connect(addr1).setApprovalForAll(teavault.address, true);
        await tx.wait();

        await expect(teavault.connect(addr1).deposit1155Batch(erc1155.address, [ 0, 1 ], [ amount0, amount1 ])).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
        await expect(teavault.connect(addr1).withdraw1155Batch(addr1.address, erc1155.address, [ 0, 1 ], [ amount0, amount1 ])).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
    });    

    it("DepositETH and withdrawETH", async function() {
        const amount = parseEther("10");

        let tx = await teavault.connect(investor).depositETH(amount, { value: amount });
        await tx.wait();

        let balance = await ethers.provider.getBalance(teavault.address);
        expect(balance).to.equal(amount);

        tx = await teavault.connect(investor).withdrawETH(investor.address, amount);
        await tx.wait();

        balance = await ethers.provider.getBalance(teavault.address);
        expect(balance).to.equal("0");
    });

    it("DepositETH with wrong amount", async function() {
        const amount1 = parseEther("10");
        const amount2 = parseEther("11");

        await expect(teavault.connect(investor).depositETH(amount1, { value: amount2 })).to.be.revertedWithCustomError(teavault, "IncorrectValue");
    });

    it("DepositETH and withdrawETH from wrong address", async function() {
        const amount = parseEther("10");

        await expect(teavault.connect(addr1).depositETH(amount, { value: amount })).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
        await expect(teavault.connect(addr1).withdrawETH(addr1.address, amount)).to.be.revertedWithCustomError(teavault, "CallerIsNotInvestor");
    });

    it("Should pass with allowed approvals", async function () {
        const iface = new ethers.utils.Interface([
            "function approve(address spender, uint256 amount) external returns (bool)"
        ]);

        const amount = parseEther("100");
        const args = iface.encodeFunctionData("approve", [ dummy.address, amount ]);
        const tx = await teavault.connect(manager).managerCall(erc20.address, 0, args);
        await tx.wait();

        // check allowance
        const allowance = await erc20.allowance(teavault.address, dummy.address);
        expect(allowance).to.equal(amount);
    });

    it("Should not pass with unallowed approvals", async function () {
        const iface = new ethers.utils.Interface([
            "function approve(address spender, uint256 amount) external returns (bool)"
        ]);

        const amount = parseEther("100");
        const args = iface.encodeFunctionData("approve", [ addr1.address, amount ]);
        await expect(teavault.connect(manager).managerCall(erc20.address, 0, args)).to.be.revertedWith("Spender not approved");

        // check allowance
        const allowance = await erc20.allowance(teavault.address, addr1.address);
        expect(allowance).to.equal("0");
    });

    it("Should not pass with not-whitelisted functions", async function () {
        const iface = new ethers.utils.Interface([
            "function transfer(address to, uint256 amount) external returns (bool)"
        ]);

        // deposit token to teavault
        const amount = parseEther("100");
        let tx = await erc20.connect(investor).approve(teavault.address, amount);
        await tx.wait();

        tx = await teavault.connect(investor).deposit(erc20.address, amount);
        await tx.wait();

        const args = iface.encodeFunctionData("transfer", [ addr1.address, amount ]);
        await expect(teavault.connect(manager).managerCall(erc20.address, 0, args)).to.be.revertedWith("Function is not whitelisted");
    });

    it("Should not pass with not-whitelisted contracts", async function () {
        const iface = new ethers.utils.Interface([
            "function assignAllowedSpender(address _spender, bool _allow)"
        ]);

        const args = iface.encodeFunctionData("assignAllowedSpender", [ addr1.address, true ]);
        await expect(teavault.connect(manager).managerCall(erc20Filter.address, 0, args)).to.be.revertedWithCustomError(teavault, "ContractNotInWhitelist");
    });

    it("Should not pass when called from wrong address", async function () {
        const iface = new ethers.utils.Interface([
            "function approve(address spender, uint256 amount) external returns (bool)"
        ]);

        const amount = parseEther("100");
        const args = iface.encodeFunctionData("approve", [ dummy.address, amount ]);
        await expect(teavault.connect(investor).managerCall(erc20.address, 0, args)).to.be.revertedWithCustomError(teavault, "CallerIsNotManager");
    });

    it("Test managerCallMulti", async function () {
        const iface = new ethers.utils.Interface([
            "function approve(address spender, uint256 amount) external returns (bool)"
        ]);

        const amount1 = parseEther("100");
        const amount2 = parseEther("200");
        const args1 = iface.encodeFunctionData("approve", [ dummy.address, amount1 ]);
        const args2 = iface.encodeFunctionData("approve", [ dummy.address, amount2 ]);
        const tx = await teavault.connect(manager).managerCallMulti(
            [ erc20.address, erc20.address ],
            [ 0, 0 ],
            [ args1, args2 ]);
        await tx.wait();

        // check allowance
        const allowance = await erc20.allowance(teavault.address, dummy.address);
        expect(allowance).to.equal(amount2);
    });

    it("Test managerCallMulti from wrong address", async function () {
        const iface = new ethers.utils.Interface([
            "function approve(address spender, uint256 amount) external returns (bool)"
        ]);

        const amount1 = parseEther("100");
        const amount2 = parseEther("200");
        const args1 = iface.encodeFunctionData("approve", [ dummy.address, amount1 ]);
        const args2 = iface.encodeFunctionData("approve", [ dummy.address, amount2 ]);
        await expect(teavault.connect(investor).managerCallMulti(
            [ erc20.address, erc20.address ],
            [ 0, 0 ],
            [ args1, args2 ])).to.be.revertedWithCustomError(teavault, "CallerIsNotManager");
    });

    it("Test EIP-1271", async function() {
        const message = "Test message";
        const hash = ethers.utils.hashMessage(message);

        // test signature from owner
        let signature = await admin.signMessage(message);
        let result = await teavault.isValidSignature(hash, signature);
        expect(result).to.equal("0x1626ba7e");

        // test incorrect signature from non owner
        result = await teavault.isValidSignature(hash, "0x1234");
        expect(result).to.equal("0xffffffff");
        
        // test signature from non owner
        signature = await addr1.signMessage(message);
        result = await teavault.isValidSignature(hash, signature);
        expect(result).to.equal("0xffffffff");

        // test signature from manager without setAllowManagerSignature
        let tx = await teavault.setAllowManagerSignature(false);
        await tx.wait();

        signature = await manager.signMessage(message);
        result = await teavault.isValidSignature(hash, signature);
        expect(result).to.equal("0xffffffff");

        // test signature from manager with setAllowManagerSignature
        tx = await teavault.setAllowManagerSignature(true);
        await tx.wait();
        
        signature = await manager.signMessage(message);
        result = await teavault.isValidSignature(hash, signature);
        expect(result).to.equal("0x1626ba7e");
    });
});

describe("TeaVaultV2Deployer", function () {

    let admin: SignerWithAddress;
    let user: SignerWithAddress;

    it("Test deployment", async function() {
        [admin, user] = await ethers.getSigners();

        // deploy deployer
        const TeaVaultV2Deployer = await ethers.getContractFactory("TeaVaultV2Deployer");
        const deployer = await TeaVaultV2Deployer.deploy();

        const salt = "0x123456" + "0".repeat(58);
        const predictedAddress = await deployer.connect(user).predictedAddress(salt);
        expect(await ethers.provider.getCode(predictedAddress)).to.equal("0x");

        const tx = await deployer.connect(user).deploy(salt);
        await tx.wait();

        const code = await ethers.provider.getCode(predictedAddress);
        expect(code).to.not.equal("0x");

        // test get owner
        const TeaVaultV2 = await ethers.getContractFactory("TeaVaultV2");
        const teavault = TeaVaultV2.attach(predictedAddress);
        const owner = await teavault.owner();

        expect(owner).to.equal(user.address);;
    });
});
