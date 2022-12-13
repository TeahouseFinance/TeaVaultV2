// UniswapRouterFilter test
// requires an archive node for forking

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { network, ethers } from "hardhat";
import { ERC20Filter, FilterMapper, TeaVaultV2, UniswapNFTFilter, UniswapRouterFilter } from "../typechain";
import USDC_CONTRACT_ABI from "./abi/ERC20.json";
import UNISWAP_NFT_ABI from "./abi/UniswapNFT.json";

require('dotenv').config();

const parseEther = ethers.utils.parseEther;

let admin: SignerWithAddress;
let manager: SignerWithAddress;
let investor: SignerWithAddress;

let teavault: TeaVaultV2;
let filterMapper: FilterMapper;
let erc20Filter: ERC20Filter;
let uniswapRouterFilter: UniswapRouterFilter;
let uniswapNFTFilter: UniswapNFTFilter;
let usdc: Contract;
let uniswapNFT: Contract;

let usdcAddr: string;
let wethAddr: string;
let routerAddr: string;
let nftAddr: string;

async function configureContracts(startingBlockNumber: number) {
    // reset to the block number
    const rpc = process.env.UNISWAP_TEST_RPC || "";
    if (rpc == "") {
        throw "No rpc";
    }

    await network.provider.request({
        method: "hardhat_reset",
        params: [
            {
                forking: {
                    jsonRpcUrl: rpc,
                    blockNumber: startingBlockNumber,
                },
            },
        ],
    });

    [admin, manager, investor] = await ethers.getSigners();

    // setup contracts
    const TeaVaultV2 = await ethers.getContractFactory("TeaVaultV2");
    teavault = await TeaVaultV2.deploy(admin.address);

    const FilterMapper = await ethers.getContractFactory("FilterMapper");
    filterMapper = await FilterMapper.deploy();

    let tx = await teavault.assignFilterMapper(filterMapper.address);
    await tx.wait();

    tx = await teavault.assignManager(manager.address);
    await tx.wait();

    tx = await teavault.assignInvestor(investor.address);
    await tx.wait();

    // setup erc20filter
    const ERC20Filter = await ethers.getContractFactory("ERC20Filter");
    erc20Filter = await ERC20Filter.deploy();

    usdcAddr = process.env.UNISWAP_TEST_USDC_ADDR || "";
    if (usdcAddr == "") {
        throw "UNISWAP_TEST_USDC_ADDR not set";
    }

    usdc = new ethers.Contract(usdcAddr, USDC_CONTRACT_ABI, ethers.provider);

    tx = await filterMapper.assignFilterMapping(usdcAddr, erc20Filter.address);
    await tx.wait();

    wethAddr = process.env.UNISWAP_TEST_WETH_ADDR || "";
    if (wethAddr == "") {
        throw "UNISWAP_TEST_WETH_ADDR not set";
    }
    
    tx = await filterMapper.assignFilterMapping(wethAddr, erc20Filter.address);
    await tx.wait();

    routerAddr = process.env.UNISWAP_TEST_ROUTER_ADDR || "";
    if (routerAddr == "") {
        throw "UNISWAP_TEST_ROUTER_ADDR not set";
    }

    tx = await erc20Filter.assignAllowedSpender(routerAddr, true);
    await tx.wait();

    nftAddr = process.env.UNISWAP_TEST_NFT_ADDR || "";
    if (nftAddr == "") {
        throw "UNISWAP_TEST_NFT_ADDR not set";
    }

    tx = await erc20Filter.assignAllowedSpender(nftAddr, true);
    await tx.wait();

    // setup uniswapRouterFilter
    const UniswapRouterFilter = await ethers.getContractFactory("UniswapRouterFilter");
    uniswapRouterFilter = await UniswapRouterFilter.deploy();

    tx = await filterMapper.assignFilterMapping(routerAddr, uniswapRouterFilter.address);
    await tx.wait();

    tx = await uniswapRouterFilter.assignAllowedTokens([ usdcAddr, wethAddr ], [ true, true ]);
    await tx.wait();

    // setup uniswapNFTFilter
    const UniswapNFTFilter = await ethers.getContractFactory("UniswapNFTFilter");
    uniswapNFTFilter = await UniswapNFTFilter.deploy();

    tx = await filterMapper.assignFilterMapping(nftAddr, uniswapNFTFilter.address);
    await tx.wait();

    tx = await uniswapNFTFilter.assignAllowedTokens([ usdcAddr, wethAddr ], [ true, true ]);
    await tx.wait();

    uniswapNFT = new ethers.Contract(nftAddr, UNISWAP_NFT_ABI, ethers.provider);
}

async function swapTest() {
    console.log("swapTest");

    // deposit
    let tx = await teavault.connect(investor).depositETH(parseEther("100"), { value: parseEther("100") });
    await tx.wait();

    // balance before
    let balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance before: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance before: ", ethers.utils.formatUnits(balance, 6));

    // try swap eth to usdc from manager
    let calldata = "0x5ae401dc" +
        "0000000000000000000000000000000000000000000000000000000062a316c4" + 
        "0000000000000000000000000000000000000000000000000000000000000040" + 
        "0000000000000000000000000000000000000000000000000000000000000001" + 
        "0000000000000000000000000000000000000000000000000000000000000020" + 
        "00000000000000000000000000000000000000000000000000000000000000e4" + 
        "04e45aaf" +
        "000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" +
        "000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48" +
        "00000000000000000000000000000000000000000000000000000000000001f4" +
        "000000000000000000000000" + teavault.address.slice(2) +
        "0000000000000000000000000000000000000000000000000de0b6b3a7640000" +
        "0000000000000000000000000000000000000000000000000000000069510ac5" +
        "0000000000000000000000000000000000000000000000000000000000000000" +
        "00000000000000000000000000000000000000000000000000000000";

    console.log("swap ETH->USDC");
    tx = await teavault.connect(manager).managerCall(routerAddr, parseEther("1"), calldata);
    await tx.wait();

    // balance after
    balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance after: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance after: ", ethers.utils.formatUnits(balance, 6));

    // approve USDC
    const iface = new ethers.utils.Interface([
        "function approve(address spender, uint256 amount) external returns (bool)"
    ]);

    const amount = "10000000000";
    const args = iface.encodeFunctionData("approve", [ routerAddr, amount ]);
    tx = await teavault.connect(manager).managerCall(usdcAddr, 0, args);
    await tx.wait();

    // try swap usdc to eth from manager
    calldata = "0x5ae401dc" + 
        "0000000000000000000000000000000000000000000000000000000062a6b305" +
        "0000000000000000000000000000000000000000000000000000000000000040" +
        "0000000000000000000000000000000000000000000000000000000000000002" +
        "0000000000000000000000000000000000000000000000000000000000000040" +
        "0000000000000000000000000000000000000000000000000000000000000160" +
        "00000000000000000000000000000000000000000000000000000000000000e4" +
        "04e45aaf" +
        "000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48" +
        "000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" +
        "0000000000000000000000000000000000000000000000000000000000000bb8" +
        "0000000000000000000000000000000000000000000000000000000000000002" +
        "000000000000000000000000000000000000000000000000000000003B9ACA00" +
        "00000000000000000000000000000000000000000000000007b5bad595e238e3" +
        "0000000000000000000000000000000000000000000000000000000000000000" +
        "00000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000044" +
        "49404b7c" +
        "00000000000000000000000000000000000000000000000007b5bad595e238e3" +
        "000000000000000000000000" + teavault.address.slice(2) +
        "00000000000000000000000000000000000000000000000000000000";

    console.log("swap USDC->ETH");
    tx = await teavault.connect(manager).managerCall(routerAddr, 0, calldata);
    await tx.wait();

    // balance after
    balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance after: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance after: ", ethers.utils.formatUnits(balance, 6));
}

async function lpTest() {
    console.log("lpTest");

    // approve USDC
    let iface = new ethers.utils.Interface([
        "function approve(address spender, uint256 amount) external returns (bool)"
    ]);

    const amount = "10000000000";
    let args = iface.encodeFunctionData("approve", [ nftAddr, amount ]);
    let tx = await teavault.connect(manager).managerCall(usdcAddr, 0, args);
    await tx.wait();

    // balance before
    let balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance before: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance before: ", ethers.utils.formatUnits(balance, 6));

    // try add lp
    let calldata = "0xac9650d8" +
        "0000000000000000000000000000000000000000000000000000000000000020" +
        "0000000000000000000000000000000000000000000000000000000000000002" +
        "0000000000000000000000000000000000000000000000000000000000000040" +
        "00000000000000000000000000000000000000000000000000000000000001e0" +
        "0000000000000000000000000000000000000000000000000000000000000164" +
        "88316456" +
        "000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48" +
        "000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" +
        "0000000000000000000000000000000000000000000000000000000000000bb8" +
        "000000000000000000000000000000000000000000000000000000000002e608" +
        "0000000000000000000000000000000000000000000000000000000000033450" +
        "000000000000000000000000000000000000000000000000000000000aba9500" +
        "00000000000000000000000000000000000000000000000002c68af0bb140000" +
        "000000000000000000000000000000000000000000000000000000000aba9500" +
        "0000000000000000000000000000000000000000000000000000000000000000" +
        "000000000000000000000000" + teavault.address.slice(2) +
        "0000000000000000000000000000000000000000000000000000000062a820d6" +
        "00000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000004" +
        "12210e8a" +
        "00000000000000000000000000000000000000000000000000000000";

    console.log("mint");
    tx = await teavault.connect(manager).managerCall(nftAddr, parseEther("0.2"), calldata);
    await tx.wait();

    // balance after
    balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance after: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance after: ", ethers.utils.formatUnits(balance, 6));    

    // get tokenId
    const tokenId = await uniswapNFT.tokenOfOwnerByIndex(teavault.address, 0);
    console.log("TokenId:", tokenId.toString());

    // add liquidity
    const increaseLiquidity = uniswapNFT.interface.encodeFunctionData("increaseLiquidity", [ {
        tokenId: tokenId,
        amount0Desired: "200000000",
        amount1Desired: parseEther("0.2"),
        amount0Min: "200000000",
        amount1Min: 0,
        deadline: "0x62a820d6"
    } ]);
    const refundEth = uniswapNFT.interface.encodeFunctionData("refundETH", []);
    calldata = uniswapNFT.interface.encodeFunctionData("multicall", [ [ increaseLiquidity, refundEth ] ]);

    console.log("increaseLiquidity");
    tx = await teavault.connect(manager).managerCall(nftAddr, parseEther("0.2"), calldata);
    await tx.wait();

    // balance after
    balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance after: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance after: ", ethers.utils.formatUnits(balance, 6));

    // get total liquidity
    const positions = await uniswapNFT.positions(tokenId);
    console.log("Total liquidity:", positions.liquidity.toString());

    // remove liquidity
    const removeLiquidity = uniswapNFT.interface.encodeFunctionData("decreaseLiquidity", [ {
        tokenId: tokenId,
        liquidity: positions.liquidity,
        amount0Min: "0",
        amount1Min: "0",
        deadline: "0x62a820d6"
    }]);
    calldata = uniswapNFT.interface.encodeFunctionData("multicall", [ [ removeLiquidity ] ]);

    console.log("decreaseLiquidity");
    tx = await teavault.connect(manager).managerCall(nftAddr, 0, calldata);
    await tx.wait();

    // balance after (should not changed)
    balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance after: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance after: ", ethers.utils.formatUnits(balance, 6));
    
    // collect
    const collect = uniswapNFT.interface.encodeFunctionData("collect", [ {
        tokenId: tokenId,
        recipient: "0x" + "0".repeat(40),
        amount0Max: "0xffffffffffffffffffffffffffffffff",
        amount1Max: "0xffffffffffffffffffffffffffffffff"
    }]);
    const unwrapWeth = uniswapNFT.interface.encodeFunctionData("unwrapWETH9", [ parseEther("0.1"), teavault.address ]);
    const sweepToken = uniswapNFT.interface.encodeFunctionData("sweepToken", [ usdc.address, "1", teavault.address ]);
    calldata = uniswapNFT.interface.encodeFunctionData("multicall", [ [ collect, unwrapWeth, sweepToken ] ]);

    console.log("collect");
    tx = await teavault.connect(manager).managerCall(nftAddr, 0, calldata);
    await tx.wait();

    // balance after
    balance = await ethers.provider.getBalance(teavault.address);
    console.log("ETH balance after: ", ethers.utils.formatUnits(balance));

    balance = await usdc.balanceOf(teavault.address);
    console.log("USDC balance after: ", ethers.utils.formatUnits(balance, 6));

    // burn
    const burn = uniswapNFT.interface.encodeFunctionData("burn", [ tokenId ]);
    calldata = uniswapNFT.interface.encodeFunctionData("multicall", [ [ burn ] ]);

    console.log("burn");
    tx = await teavault.connect(manager).managerCall(nftAddr, 0, calldata);
    await tx.wait();
}

async function main() {
    // check network
    if (network.name != 'hardhat') {
        throw "Must be on hardhat network";
    }

    const blockNumber = process.env.UNISWAP_TEST_BLOCK_NUMBER || "";
    await configureContracts(parseInt(blockNumber));

    await swapTest();
    await lpTest();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
