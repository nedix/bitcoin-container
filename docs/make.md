# Make

## Available commands

### Setup

Build the container.

Command: `make setup`


### Destroy

Stop the container and remove volumes.

Command: `make destroy`


### Up

Start the container.

Command: `make up`

Options:

| Option key                | Default value |
|---------------------------|---------------|
| RPC_MAINNET_PORT          | 8332          |
| RPC_TESTNET_PORT          | 18332         |
| RPC_REGNET_PORT           | 18443         |
| P2P_MAINNET_PORT          | 8333          |
| P2P_TESTNET_PORT          | 18333         |
| P2P_REGNET_PORT           | 18444         |
| ZMQ_RAW_TRANSACTION_PORT  | 28332         |
| ZMQ_RAW_BLOCK_PORT        | 28333         |
| ZMQ_TRANSACTION_HASH_PORT | 28334         |
| ZMQ_BLOCK_HASH_PORT       | 28335         |
| ZMQ_MEMPOOL_SEQUENCE_PORT | 28336         |

### Down

Stop the container.

Command: `make down`


### Shell

Attach an interactive shell to the container.

Command: `make shell`


### Test

Run all tests.

Command: `make test`
