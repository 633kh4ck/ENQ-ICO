let Networks = {
	mainnet: 1,
	morden: 2,
	ropsten: 3
};
	
module.exports = network => {
	return Networks[network];
};