import { InputTransactionData } from "@aptos-labs/wallet-adapter-react"
import { getAptosClient } from "@/common/aptosClient"

export enum CounterAction {
  Increment = 1,
  Decrement,
  Random,
}

export type CounterRecordEvent = {
  timestamp_us: number
  action: CounterAction
  user: string
  value: string
}

export type CounterRecord = {
  timestamp_us: number
  action: CounterAction
  user: string
}

const CollectionModuleName = {
  Fibonacci: "fibonacci",
  PrimeNumber: "prime_number",
  Linear: "linear",
} as const

type CollectionModuleNameKey = keyof typeof CollectionModuleName

export function getCollectionModuleNameFromId(id: string): string {
  const collectionName = [
    "fibonacci",
    "prime_number",
    "linear",
  ] as const

  return collectionName[Number(id)]
}

export type CollectionMetadata = {
  name: string
  description: string
  uri: string
  max_supply: number
}

const MODULE_ADDRESS = "0x5ed4664ecfac74f55a37fb7d1122eee8925d93216076cdf0ca9a0e53f495a0eb"

const aptos = getAptosClient()

export async function getValue(collectionId: string): Promise<number> {
  const [value] = await aptos.view<number[]>({
    payload: {
      function: `${MODULE_ADDRESS}::count::get_value`,
      functionArguments: [
        collectionId,
      ],
    },
  })

  return Number(value)
}

export function getCollectionId(input: string) {
  const COLLECTION_NAME_ID: Record<string, number> = {
    "Fibonacci": 0,
    "Prime Number": 1,
    "Linear": 2,
  }

  return COLLECTION_NAME_ID[input] || 0
}

export async function getAllCollectionDescription(): Promise<CollectionMetadata[]> {
  return Promise.all([
    getCollectionDescription("Linear"),
    getCollectionDescription("Fibonacci"),
    getCollectionDescription("PrimeNumber"),
  ])
}

export async function getCollectionDescription(
  collectionModuleName: CollectionModuleNameKey,
): Promise<CollectionMetadata> {
  const [collectionDescription] = await aptos.view<CollectionMetadata[]>({
    payload: {
      function: `${MODULE_ADDRESS}::${CollectionModuleName[collectionModuleName]}::get_collection_description`,
      functionArguments: [],
    },
  })

  return collectionDescription
}

export async function getAllRecords(id: string): Promise<CounterRecord[]> {
  const [allRecords] = await aptos.view<CounterRecord[][]>({
    payload: {
      function: `${MODULE_ADDRESS}::count::query_all_records`,
      functionArguments: [
        Number(id),
      ],
    },
  })

  allRecords.sort((a, b) => Number(b.timestamp_us) - Number(a.timestamp_us))

  return allRecords
}

export async function getNextValue(id: string): Promise<number> {
  const MODULE_NAME = [
    "fibonacci",
    "prime_number",
    "linear",
  ] as const

  const [nextValue] = await aptos.view<string[]>({
    payload: {
      function: `${MODULE_ADDRESS}::${MODULE_NAME[Number(id)]}::get_next_value`,
      functionArguments: [],
    },
  })

  return Number(nextValue)
}

export function incrementTransactionData(id: string): InputTransactionData {
  return {
    data: {
      function: `${MODULE_ADDRESS}::count::increment`,
      functionArguments: [
        Number(id),
      ],
    },
  }
}

export function decrementTransactionData(id: string): InputTransactionData {
  return {
    data: {
      function: `${MODULE_ADDRESS}::count::decrement`,
      functionArguments: [
        Number(id),
      ],
    },
  }
}

export function randomTransactionData(id: string): InputTransactionData {
  return {
    data: {
      function: `${MODULE_ADDRESS}::count::random`,
      functionArguments: [
        Number(id),
      ],
    },
  }
}
