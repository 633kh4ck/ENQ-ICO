require('dotenv').config();
const utils = require('./utils');
const HDWalletProvider = require('truffle-hdwallet-provider');
const LedgerWalletProvider = require("truffle-ledger-provider");

const providerWithMnemonic = (mnemonic, rpcEndpoint) => new HDWalletProvider(mnemonic, rpcEndpoint);
const providerWithLedger = (options, rpcEndpoint) => new LedgerWalletProvider(options, rpcEndpoint);
const infuraProvider = network => process.env.MNEMONIC ? providerWithMnemonic(
	process.env.MNEMONIC,
	`https://${network}.infura.io/${process.env.INFURA_API_KEY}`
) : providerWithLedger({
		networkId: utils.resolveNetworkByName(network),
		path: "44'/60'/0'/0",
		askConfirm: true,
		accountsLength: 1,
		accountsOffset: 0,
	},
	`https://${network}.infura.io/${process.env.INFURA_API_KEY}`
);

module.exports = {
	networks: {
		development: {
			host: '127.0.0.1',
			port: 8545,
			network_id: '*',
			gas: 7000000
		},
		ropsten: {
			provider: infuraProvider('ropsten'),
			network_id: 3,
			gas: 7000000
		},
		mainnet: {
			provider: infuraProvider('mainnet'),
			network_id: 1,
			gas: 7000000,
			gasPrice: 10000000000
		}
	},
	solc: {
		optimizer: {
			enabled: true,
			runs: 200
		}
	}
};