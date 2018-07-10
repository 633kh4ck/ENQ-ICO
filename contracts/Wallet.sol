pragma solidity 0.4.24;

import "multisig-wallet-gnosis/contracts/MultiSigWalletWithDailyLimit.sol";


// solium-disable-next-line max-len
contract Wallet is MultiSigWalletWithDailyLimit { // solhint-disable-line max-line-length
	constructor(
		address[] _owners,
		uint _required,
		uint _dailyLimit
	)
	public
	MultiSigWalletWithDailyLimit(_owners, _required, _dailyLimit)
	{ // solhint-disable-line bracket-align, no-empty-blocks

	}
}