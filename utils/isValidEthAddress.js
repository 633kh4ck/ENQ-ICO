const sha3 = require('./sha3.js');

let isChecksumAddress = address => {
	address = address.replace('0x','');
	var addressHash = sha3(address.toLowerCase());

	for (var i = 0; i < 40; i++ ) {
		if ((parseInt(addressHash[i], 16) > 7 && address[i].toUpperCase() !== address[i]) || (parseInt(addressHash[i], 16) <= 7 && address[i].toLowerCase() !== address[i])) {
			return false;
		}
	}
	return true;
};

module.exports = address => {
	if (!/^(0x)?[0-9a-f]{40}$/i.test(address)) {
		return false;
	} else if (/^(0x)?[0-9a-f]{40}$/.test(address) || /^(0x)?[0-9A-F]{40}$/.test(address)) {
		return true;
	} else {
		return isChecksumAddress(address);
	}
};