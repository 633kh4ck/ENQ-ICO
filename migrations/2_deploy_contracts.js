const utils = require('../utils');
const Migrations = artifacts.require('Migrations.sol')
const Wallet = artifacts.require('Wallet.sol');
const Token = artifacts.require('Token.sol');
const ICO = artifacts.require('ICO.sol');

module.exports = (deployer, network) => {
	let config = require('config.json')(`${__dirname}/../config.${network}.json`);
	console.log(`Using ${network} config`);
	
	if(!('wallet' in config) || !('token' in config) || !('ico' in config)) {
		console.error(`Specify all required args in config.${network}.json\nSee readme.md and config.example.json for more info`)
		return;
	}else{
		console.log('wallet.useDeployed:', config.wallet.useDeployed ? `${config.wallet.useDeployed} (${config.wallet.address})` : config.wallet.useDeployed);
		console.log('token.useDeployed:', config.token.useDeployed ? `${config.token.useDeployed} (${config.token.address})` : config.token.useDeployed);
		console.log('ico.useDeployed:', config.ico.useDeployed ? `${config.ico.useDeployed} (${config.ico.address})` : config.ico.useDeployed);

		if(config.wallet.useDeployed && !utils.isValidEthAddress(config.wallet.address)) {
			console.log(`Specify valid eth address for wallet contract in config.${network}.json`);
			return;
		}else if(config.token.useDeployed && !utils.isValidEthAddress(config.token.address)) {
			console.log(`Specify valid eth address for token contract in config.${network}.json`);
			return;
		}else if(config.ico.useDeployed && !utils.isValidEthAddress(config.ico.address)) {
			console.log(`Specify valid eth address for ico contract in config.${network}.json`);
			return;
		}
	}

	deployer.deploy(Migrations).then(_ => {
		console.log('To the moon...');
		return config.wallet.useDeployed ? config.wallet : deployer.deploy(Wallet,
			config.wallet.args[0],
			config.wallet.args[1],
			config.wallet.args[2]
		);
	})
	.then(instance => new Promise(resolve => setTimeout(() => resolve(instance), (network == 'mainnet') ? 60000 : 100)))
	.then(instance => {
		config.wallet = instance;
		console.log('Using wallet address:', config.wallet.address);

		return config.token.useDeployed ? config.token : deployer.deploy(Token, config.wallet.address);
	})
	.then(instance => new Promise(resolve => setTimeout(() => resolve(instance), (network == 'mainnet') ? 60000 : 100)))
	.then(instance => {
		config.token = instance;
		console.log('Using token address:', config.token.address);

		return config.ico.useDeployed ? config.ico : deployer.deploy(ICO,
			config.ico.args[0],
			config.wallet.address,
			config.token.address,
			config.ico.args[3],
			config.ico.args[4],
			config.ico.args[5],
			config.ico.args[6],
			config.ico.args[7],
			config.ico.args[8],
			config.ico.args[9],
			{value: config.ico.initialDeposit}
		);
	}).then(instance => {
		config.ico = instance;
		console.log('Using ico address:', config.ico.address);
		return;
	}).then(_=> {
		console.log(`Transfer ownership of token (${config.token.address}) to ico (${config.ico.address})`);
		Token.at(config.token.address).transferOwnership(config.ico.address);
		
		console.log(`Transfer ownership of ico (${config.ico.address}) to wallet (${config.wallet.address})`);
		ICO.at(config.ico.address).transferOwnership(config.wallet.address);
	}).then(_=> {
		console.log('Well done.');
	});
};
