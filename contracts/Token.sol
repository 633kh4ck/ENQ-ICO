pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/CappedToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

/**
 * @title ENQ Token Smart Contract
 * @author GeekHack t.me/GeekHack
 */
contract Token is CappedToken, PausableToken {
	/* solhint-disable const-name-snakecase */
	string public constant name = "Enecuum"; // solium-disable-line uppercase
	string public constant symbol = "ENQ"; // solium-disable-line uppercase
	uint8 public constant decimals = 10; // solium-disable-line uppercase
	/* solhint-enable const-name-snakecase */
	uint256 public cap = 687566880 * (10 ** uint256(decimals));

	// solium-disable-next-line max-len
	uint256 public constant INITIAL_SUPPLY = 90810720 * (10 ** uint256(decimals)); // solhint-disable-line max-line-length

	constructor(
		address _wallet
	)
	public
	CappedToken(cap)
	{ // solhint-disable-line bracket-align
		require(_wallet != address(0));
		totalSupply_ = INITIAL_SUPPLY;
		balances[_wallet] = INITIAL_SUPPLY;
		emit Transfer(address(0), _wallet, INITIAL_SUPPLY);
	}
}