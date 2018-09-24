/* solium-disable security/no-block-members */
pragma solidity 0.4.24;

/* solhint-disable max-line-length */
import "openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol"; // solium-disable-line max-len
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
/* solhint-enable max-line-length */


/**
 * @title TokenVestingWithTimeSync
 * @dev A token holder contract originally developed by
 * OpenZeppelin team that can release its token balance
 * gradually like a typical vesting scheme, with a cliff
 * and vesting period. Optionally revocable by the owner.
 *
 * Little improvements to obtain the time (as Unix time)
 * at which point vesting starts from owner (crowdsale)
 * contract. The original contract name was retained for
 * backward compatibility.
 */
contract TokenVesting is Ownable {
	using SafeMath for uint256;
	using SafeERC20 for ERC20Basic;

	event Released(uint256 amount);
	event Revoked();

	address public beneficiary;
	uint256 public cliff;
	uint256 public duration;

	bool public revocable;

	mapping (address => uint256) public released;
	mapping (address => bool) public revoked;

	/**
	 * @dev Creates a vesting contract that vests its balance
	 * of any ERC20 token to the _beneficiary, gradually in a
	 * linear fashion until _start + _duration. By then all of the balance
	 * will have vested.
	 * @param _beneficiary address of the beneficiary to whom vested tokens
	 * are transferred
	 * @param _cliff in seconds in which tokens will begin to vest
	 * @param _start the time (as Unix time) at which point vesting starts
	 * @param _duration in seconds of the period in which the tokens will vest
	 * @param _revocable whether the vesting is revocable or not
	 */
	constructor(
		address _beneficiary,
		uint256 _start, // backward compatibility
		uint256 _cliff,
		uint256 _duration,
		bool _revocable
	)
	public
	{ // solhint-disable-line bracket-align
		require(_beneficiary != address(0));
		require(_cliff <= _duration);

		beneficiary = _beneficiary;
		revocable = _revocable;
		duration = _duration;
		cliff = _cliff;
	}

	/**
	 * @notice Transfers vested tokens to beneficiary.
	 * @param _token ERC20 token which is being vested
	 */
	function release(ERC20Basic _token) public {
		uint256 unreleased = releasableAmount(_token);

		require(unreleased > 0);

		released[_token] = released[_token].add(unreleased);

		_token.safeTransfer(beneficiary, unreleased);

		emit Released(unreleased);
	}

	/**
	 * @notice Allows the owner to revoke the vesting. Tokens already vested
	 * remain in the contract, the rest are returned to the owner.
	 * @param _token ERC20 token which is being vested
	 */
	function revoke(ERC20Basic _token) public onlyOwner {
		require(revocable);
		require(!revoked[_token]);

		uint256 balance = _token.balanceOf(address(this));

		uint256 unreleased = releasableAmount(_token);
		uint256 refund = balance.sub(unreleased);

		revoked[_token] = true;

		_token.safeTransfer(owner, refund);

		emit Revoked();
	}

	/**
	 * @dev getter for beneficiary address
	 * @return address of the beneficiary
	 */
	function getBeneficiary() public view returns (address) {
		return beneficiary;
	}

	/**
	 * @dev getter for start time
	 * @return time (as Unix time) at which point vesting starts
	 */
	function getStart() public view returns (uint256) {
		return uint256(TimedCrowdsale(owner).closingTime());
	}

	/**
	 * @dev getter for cliff time
	 * @return time (as Unix time) at which tokens will begin to vest
	 */
	function getCliff() public view returns (uint256) {
		return getStart().add(cliff);
	}

	/**
	 * @dev getter for duration
	 * @return duration in seconds of the period in which the tokens will vest
	 */
	function getDuration() public view returns (uint256) {
		return duration;
	}

	/**
	 * @dev check if vesting is revocable or not
	 * @return whether the vesting is revocable or not
	 */
	function isRevocable() public view returns (bool) {
		return revocable;
	}

	/**
	 * @dev Calculates the amount that has already vested
	 * but hasn't been released yet.
	 * @param _token ERC20 token which is being vested
	 */
	function releasableAmount(ERC20Basic _token) public view returns (uint256) {
		return vestedAmount(_token).sub(released[_token]);
	}

	/**
	 * @dev Calculates the amount that has already vested.
	 * @param _token ERC20 token which is being vested
	 */
	function vestedAmount(ERC20Basic _token) public view returns (uint256) {
		uint256 currentBalance = _token.balanceOf(address(this));
		uint256 totalBalance = currentBalance.add(released[_token]);

		if (block.timestamp < getCliff()) {
			return 0;
		} else if (block.timestamp >= getStart().add(getDuration()) || revoked[_token]) {
			return totalBalance;
		} else {
			return totalBalance.mul(block.timestamp.sub(getStart())).div(getDuration());
		}
	}
}
