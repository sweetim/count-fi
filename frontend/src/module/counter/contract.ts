import { InputTransactionData } from '@aptos-labs/wallet-adapter-react';
import { getAptosClient } from '@/common/aptosClient';

export enum CounterAction {
  Increment = 1,
  Decrement,
  Random
}

export type CounterRecord = {
  timestamp_us: number,
  action: CounterAction,
  user: string
}

const MODULE_ADDRESS = "0x94c652e656ed7d99fbd44905504244be44a361b3e04abf8b5b0c342ae74ca25a"

const aptos = getAptosClient()

export async function getValue(): Promise<number> {
  const [value] = await aptos.view<number[]>({
    payload: {
      function: `${MODULE_ADDRESS}::counter::get_value`,
    }
  })

  return Number(value)
}

export async function getAllRecords(): Promise<CounterRecord[]> {
  const [allRecords] = await aptos.view<CounterRecord[][]>({
    payload: {
      function: `${MODULE_ADDRESS}::counter::query_all_records`,
    }
  })

  allRecords.sort((a, b) => Number(b.timestamp_us) - Number(a.timestamp_us))

  return allRecords
}

export function incrementTransactionData(): InputTransactionData {
  return {
    data: {
      function: `${MODULE_ADDRESS}::counter::increment`,
      functionArguments: []
    }
  }
}

export function decrementTransactionData(): InputTransactionData {
  return {
    data: {
      function: `${MODULE_ADDRESS}::counter::decrement`,
      functionArguments: []
    }
  }
}

export function randomTransactionData(): InputTransactionData {
  return {
    data: {
      function: `${MODULE_ADDRESS}::counter::random`,
      functionArguments: []
    }
  }
}
