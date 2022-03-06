require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
// require('hardhat-gas-reporter');
// require('hardhat-contract-sizer');
// require('solidity-coverage');
require("dotenv").config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.12",
        settings: {
          optimizer: {
            enabled: true,
            // runs: 800,
            runs: 100000,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    // mainnet: {
    //   url: process.env.PROVIDER_MAINNET,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    rinkeby: {
      url: process.env.PROVIDER_RINKEBY,
      accounts: [process.env.PRIVATE_KEY],
    },
    // kovan: {
    //   url: process.env.PROVIDER_KOVAN,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    // bsc: {
    //   url: process.env.PROVIDER_BSC,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    // bscTest: {
    //   url: process.env.PROVIDER_BSC_TEST,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    // polygon: {
    //   url: process.env.PROVIDER_POLYGON,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
    // mumbai: {
    //   url: process.env.PROVIDER_MUMBAI,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
  },
  mocha: {
    timeout: 0,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
    // apiKey: process.env.BSCSCAN_KEY,
    // apiKey: process.env.SNOWTRACE_KEY,
    // apiKey: process.env.POLYGONSCAN_KEY,
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    gasPrice: 100,
    coinmarketcap: "62e54920-2a0e-4644-a32b-59e48dc999ac",
  },
};
