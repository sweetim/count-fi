import { aptos } from "@aptos-labs/aptos-protos";
import { ChannelCredentials, Metadata } from "@grpc/grpc-js";
import { Realtime } from "ably"



const STARTING_VERSION = "986962"
const APTOS_DEVNET_CHAIN_ID = 131
const APTOS_COUNTER_MODULE_ADDRESS = "0x25eeef73f1b22092fc2a57a8647f12afb1606d16ebe0c4afd675517402dd2e56"
const APTOS_COUNTER_EVENT_TYPE = `${APTOS_COUNTER_MODULE_ADDRESS}::counter::CounterRecordEvent`

const client = new aptos.indexer.v1.RawDataClient(
  GRPC_STREAM_ENDPOINT_URL,
  ChannelCredentials.createSsl(),
  {
    "grpc.keepalive_permit_without_calls": 1,
    // "grpc.keepalive_time_ms": 1000,
    // 0 - No compression
    // 1 - Compress with DEFLATE algorithm
    // 2 - Compress with GZIP algorithm
    // 3 - Stream compression with GZIP algorithm
    "grpc.default_compression_algorithm": 2,
    // 0 - No compression
    // 1 - Low compression level
    // 2 - Medium compression level
    // 3 - High compression level
    "grpc.default_compression_level": 3,
    // -1 means unlimited
    "grpc.max_receive_message_length": -1,
    // -1 means unlimited
    "grpc.max_send_message_length": -1,
  },
)

const metadata = new Metadata()
metadata.set(
  "Authorization",
  `Bearer ${GRPC_STREAM_API_KEY}`,
)

const request = {
  startingVersion: BigInt(STARTING_VERSION)
}

const ably = new Realtime(ABLY_API_KEY)
const channel = ably.channels.get(ABLY_APTOS_COUNTER_CHANNEL_NAME)

const stream = client.getTransactions(request, metadata)
stream.on(
  "data",
  async (response: aptos.indexer.v1.TransactionsResponse) => {
    stream.pause()
    const transactions = response.transactions || []
    for (const transaction of transactions) {
      if (transaction.type !== aptos.transaction.v1.Transaction_TransactionType.TRANSACTION_TYPE_USER) {
        continue;
      }

      const events = transaction.user?.events || []
      for (const ev of events) {
        if (ev.typeStr?.includes("0x25eeef73f1b22092fc2a57a8647f12afb1606d16ebe0c4afd675517402dd2e56")) {
          await channel.publish(ev)
          console.log(ev)
        }
        // console.log(transaction.version, ev.typeStr)
      }

      // console.log(transaction.user?.events)
    }

    // const aptosCounterEv = response.transactions?.
    //   filter(r => r.blockMetadata?.events?.some(ev => ev.typeStr === APTOS_COUNTER_EVENT_TYPE))

    // console.log(aptosCounterEv)
    stream.resume()
    // console.log(response.transactions && response.transactions[0].blockMetadata?.events)
  })
