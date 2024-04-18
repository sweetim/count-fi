import { Realtime } from "ably"

const ABLY_API_KEY = "y8qZUw.hcEQoQ:fOh7nEkxRV8oP4KnJqV0pjKy-qcjF1yh-vEhyYAVbsA"
export const ABLY_APTOS_COUNTER_CHANNEL_NAME = "aptos-counter"

export function getAblyClient() {
  const client = new Realtime({
    key: ABLY_API_KEY
  })

  return client
}
