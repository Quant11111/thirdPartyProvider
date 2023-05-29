import { HardhatUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@nomiclabs/hardhat-etherscan";
import "@openzeppelin/hardhat-upgrades";
const dotenv = require("dotenv");
dotenv.config();

const gasPriceApi = {
  eth: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
  bnb: "https://api.bscscan.com/api?module=proxy&action=eth_gasPrice",
  matic: "https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice",
  avax: "https://api.snowtrace.io/api?module=proxy&action=eth_gasPrice",
};

const config: HardhatUserConfig = {
  gasReporter: {
    enabled: process.env.GAS_REPORTER_ENABLED === "true",
    noColors: true,
    currency: "USD",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    token: "MATIC",
    gasPriceApi: gasPriceApi.matic,
    showTimeSpent: false,
    outputFile: "gas-report.txt",
  },
  networks: {
    matic: {
      url: "https://matic-mumbai.chainstacklabs.com/",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
      allowUnlimitedContractSize: true,
    },
    mumbai: {
      url: "https://matic-mumbai.chainstacklabs.com/",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
    },
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY,
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};

export default config;
