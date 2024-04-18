import { InputTransactionData } from '@aptos-labs/wallet-adapter-react';
import { getAptosClient } from '@/common/aptosClient';

export enum CounterAction {
  Increment = 1,
  Decrement,
  Random
}

export type CounterRecordEvent = {
  timestamp_us: number,
  action: CounterAction,
  user: string,
  value: string
}

export type CounterRecord = {
  timestamp_us: number,
  action: CounterAction,
  user: string
}

const MODULE_ADDRESS = "0x25eeef73f1b22092fc2a57a8647f12afb1606d16ebe0c4afd675517402dd2e56"

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
