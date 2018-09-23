ENQ ICO Smart Contracts
===================
ENQ ICO is based on the ERC20 token, [OpenZeppelin framework](https://github.com/OpenZeppelin/openzeppelin-solidity), [MultiSig Wallet (by Gnosis)](https://github.com/gnosis/MultiSigWallet) and some utilitarian contracts. All contracts use the latest stable version of the Solidity language (except dependencies, which we can't control) and have passed internal tests and audits.

![ENQ](https://raw.githubusercontent.com/633kh4ck/ENQ-ICO/master/docs/diagram.png)

## Install

``` bash
# resolve multisig-wallet-gnosis dependency
$ npm i --save gnosis/MultiSigWallet # Or fix it manually by placing code in the ../MultiSigWallet directory

# install dependencies
$ npm install # Or yarn install
```

## Deploy

``` bash
# configure your infura api key & ( mnemonic || ledger )
$ cp env.example env
$ nano env

# configure your args (each network has separate config file)
# all args are placed in order like constructors params
$ cp config.example.json config.development.json # Or config.ropsten.json etc

# compile project
$ npm run compile # Or truffle compile (if truffle installed globally)

# deploy contracts
$ npm run migrate -- --network development # Or truffle migrate --network development (specify network)
```

## Security

All code is secure and well tested, but I take no responsibility for your implementation decisions and any security problem you might experience. All contracts are WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
<!--
## Deployed instances

- Ropsten
  - Wallet [0x0](https://ropsten.etherscan.io/address/0xcafe1a77e84698c83ca8931f54a755176ef75f2c)
  - Token [0x0](https://ropsten.etherscan.io/address/0x5894110995b8c8401bd38262ba0c8ee41d4e4658)
  - ICO [0x0](https://ropsten.etherscan.io/address/0x7da82c7ab4771ff031b66538d2fb9b0b047f6cf9)
-->
## License

Code released under the [AGPL v3](LICENSE).
