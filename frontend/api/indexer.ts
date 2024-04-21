import type { VercelRequest, VercelResponse } from '@vercel/node'
import { Realtime } from "ably"

const {
  ABLY_API_KEY,
  APTOS_COUNTER_MODULE_ADDRESS,
} = process.env

const ABLY_APTOS_COUNTER_CHANNEL_NAME = "aptos-counter"

const APTOS_COUNTER_RECORD_EVENT_NAME = `${APTOS_COUNTER_MODULE_ADDRESS}::counter::CounterRecordEvent`

const ably = new Realtime(ABLY_API_KEY!)
const channel = ably.channels.get(ABLY_APTOS_COUNTER_CHANNEL_NAME);

export function GET(request: VercelRequest) {
  return new Response(`Hello ${Date.now()}`)
}

export async function POST(request: Request) {
  const data = await request.json()

  const ev = data.events
      .filter(({ type }: any) => type === APTOS_COUNTER_RECORD_EVENT_NAME)
      .map(({ data }: any) => data)
      .flat();

  console.log(ev)

  await channel.publish({
    data: ev
  })

  return new Response()
}
