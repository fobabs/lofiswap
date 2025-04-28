# LofiSwap

**LofiSwap** is a simple decentralized exchange inspired by Uniswap v1.  
It focuses on simplicity and core automated market maker (AMM) mechanics.

## Features

- Liquidity pools for token trading
- Constant product market maker (x * y = k)
- Basic swap functionality
- Liquidity provisioning and removal
- Minimalistic and gas-efficient

## Project Structure

```plaintext
.
├── lib/                 # External libraries
├── script/              # Deployment scripts
├── src/                 # Smart contracts
├── test/                # Unit tests
├── foundry.toml         # Foundry configuration
├── gas-report.txt       # Gas usage snapshot
└── package.json         # Package management
```

## Tech Stack

- **Solidity** for smart contracts
- **Foundry** for development, testing, and deployment

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/) installed  
  Install Foundry with:

  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```

- RPC Provider URL (e.g., from Alchemy or Infura)
- Private key for deploying contracts

### Installation

Clone the repository:

```bash
git clone https://github.com/fobabs/lofiswap.git
cd lofiswap
```

Install dependencies:

```bash
forge install
```

### Building Contracts

```bash
forge build
```

### Running Tests

```bash
forge test
```

### Gas Reporting

Generate gas snapshots:

```bash
forge snapshot
```

Check the generated `gas-report.txt` and `gas-snapshot` for detailed gas usage.

### Deployment

Deploy contracts using a script:

```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY>
```

Replace `<YOUR_RPC_URL>` and `<YOUR_PRIVATE_KEY>` with your actual values.

### Local Development

Run a local Ethereum node:

```bash
anvil
```

Interact with contracts using:

```bash
cast <subcommand>
```

## Contributing

Contributions are welcome.  
Please fork the repository, create a new branch, and submit a pull request.

## License

This project is open-source and available under the MIT License.

## Acknowledgments

- Inspired by [Uniswap V1](https://github.com/runtimeverification/publications/blob/main/reports/smart-contracts/Uniswap-V1.pdf)
- Built using [Foundry](https://book.getfoundry.sh/)
