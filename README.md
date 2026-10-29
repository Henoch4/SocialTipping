# Social Tipping

**Native BOT tips with a message attached.**

Live on **BOT Chain mainnet (chain ID 677)**.

| | |
|---|---|
| Contract | `0xad80E12Aa6765a427Dc9BA76060578336A67716a` |
| Network | BOT Chain Mainnet |
| Chain ID | 677 |
| RPC | https://rpc.botchain.ai |
| Explorer | https://scan.botchain.ai/ |
| Website | https://botchain.ai |

## What it does

Creators register a handle once. Anyone can then tip their address with a note. Tips accrue under the creator and are withdrawn in a single transfer — no platform cut and no payout threshold.

## Functions

- `registerCreator(handle) — one handle per address`
- `tip(creator, message) — payable`
- `withdrawTips() — creator pulls the full accrued balance`

## Frontend

A single self-contained `index.html` — no build step, no bundler. Open it directly or serve the folder statically.

- Wallet connect through any injected EIP-1193 wallet (MetaMask, OKX Wallet).
- If chain 677 is not configured, the page offers to add it (`wallet_addEthereumChain`).
- Every number on the page is read live from the contract over JSON-RPC; nothing is mocked.
- All writes are sent from the connected account and confirmed before the UI refreshes.

```bash
# any static server works
npx serve .
```

## Contract

`contracts/SocialTipping.sol` — self-contained Solidity 0.8.20, no external imports. Reentrancy guard and ownership are declared inline so the file compiles standalone with `solc`.

## License

MIT
