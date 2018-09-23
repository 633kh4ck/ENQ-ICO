pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/rbac/RBAC.sol";


/**
 * @title Manager
 * @dev The Manager contract has a manager list of addresses,
 * and provides basic authorization control functions.
 * This simplifies the implementation of "manager permissions".
 */
contract Manager is Ownable, RBAC {
	string public constant ROLE_MANAGER = "manager";

	/**
	 * @dev Throws if called by any account not from manager list.
	 */
	modifier onlyManager() {
		checkRole(msg.sender, ROLE_MANAGER);
		_;
	}

	/**
	 * @dev Throws if operator is not in manager list.
	 * @param _operator address
	 */
	modifier onlyIfManager(address _operator) {
		checkRole(_operator, ROLE_MANAGER);
		_;
	}

	/**
	 * @dev add an address to the manager list
	 * @param _operator address
	 * @return true if the address was added to the manager list,
	 * false if the address was already in the manager list
	 */
	function addAddressToManagerList(address _operator)	public onlyOwner {
		addRole(_operator, ROLE_MANAGER);
	}

	/**
	 * @dev getter to determine if address is in manager list
	 */
	function hasManagerRole(address _operator) public view returns (bool) {
		return hasRole(_operator, ROLE_MANAGER);
	}

	/**
	 * @dev add addresses to the manager list
	 * @param _operators addresses
	 * @return true if at least one address was added to the manager list,
	 * false if all addresses were already in the manager list
	 */
	function addAddressesToManagerList(address[] _operators) public onlyOwner {
		for (uint256 i = 0; i < _operators.length; i++) {
			addAddressToManagerList(_operators[i]);
		}
	}

	/**
	 * @dev remove an address from the manager list
	 * @param _operator address
	 * @return true if the address was removed from the manager list,
	 * false if the address wasn't in the manager list in the first place
	 */
	function removeAddressFromManagerList(address _operator) public onlyOwner {
		removeRole(_operator, ROLE_MANAGER);
	}

	/**
	 * @dev remove addresses from the manager list
	 * @param _operators addresses
	 * @return true if at least one address was removed from the manager list,
	 * false if all addresses weren't in the manager list in the first place
	 */
	// solium-disable-next-line max-len
	function removeAddressesFromManagerList(address[] _operators) public onlyOwner { // solhint-disable-line max-line-length
		for (uint256 i = 0; i < _operators.length; i++) {
			removeAddressFromManagerList(_operators[i]);
		}
	}
}