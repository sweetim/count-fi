import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";

const NETWORK = Network.TESTNET

export function getAptosClient() {
  const aptosConfig = new AptosConfig({ network: NETWORK });
  const aptos = new Aptos(aptosConfig);

  return aptos
}

export function getAptosExplorerUrl(account: string): string {
  return `https://explorer.aptoslabs.com/account/${account}?network=${NETWORK}`
}
