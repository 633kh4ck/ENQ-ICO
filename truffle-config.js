require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');

const providerWithMnemonic = (mnemonic, rpcEndpoint) => new HDWalletProvider(mnemonic, rpcEndpoint);
const infuraProvider = network => providerWithMnemonic(
	process.env.MNEMONIC || '',
	`https://${network}.infura.io/${process.env.INFURA_API_KEY}`
);

module.exports = {
	networks: {
		development: {
			host: '127.0.0.1',
			port: 8545,
			network_id: '*'
		},
		ropsten: {
			provider: infuraProvider('ropsten'),
			network_id: 3,
			gas: 3500000
		},
		mainnet: {
			provider: infuraProvider('mainnet'),
			network_id: 1,
			gas: 3500000
		}
	}
};