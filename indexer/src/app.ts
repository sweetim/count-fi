import { aptos } from "@aptos-labs/aptos-protos";
import { ChannelCredentials, Metadata } from "@grpc/grpc-js";
import { Realtime } from "ably"
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk"
import Fastify from "fastify";

import "dotenv/config"

const {
  GRPC_STREAM_API_KEY,
  GRPC_STREAM_ENDPOINT_URL,
  ABLY_API_KEY,
  APTOS_COUNTER_MODULE_ADDRESS
} = process.env

const ABLY_APTOS_COUNTER_CHANNEL_NAME = "aptos-counter"

const aptosClient = new Aptos(new AptosConfig({
  network: Network.TESTNET
}))

const client = new aptos.indexer.v1.RawDataClient(
  GRPC_STREAM_ENDPOINT_URL!,
  ChannelCredentials.createSsl(),
  {
    // "grpc.keepalive_permit_without_calls": 1,
    "grpc.keepalive_time_ms": 10000000,
    "grpc.default_compression_algorithm": 2,
    "grpc.default_compression_level": 3,
    "grpc.max_receive_message_length": -1,
    "grpc.max_send_message_length": -1,
  },
)

const metadata = new Metadata()
metadata.set(
  "Authorization",
  `Bearer ${GRPC_STREAM_API_KEY}`,
)

const ably = new Realtime(ABLY_API_KEY!)
const channel = ably.channels.get(ABLY_APTOS_COUNTER_CHANNEL_NAME);

const fastify = Fastify({
  logger: true
});

(async () => {
  const latestBlock = await aptosClient.getIndexerLastSuccessVersion()
  console.log(`started listening from block (${latestBlock})`)

  const request = {
    startingVersion: BigInt(latestBlock)
  }

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
          if (ev.typeStr?.includes(APTOS_COUNTER_MODULE_ADDRESS!)) {
            await channel.publish(ev)
            console.log(ev)
          }
        }
      }

      stream.resume()
    })

    await fastify.listen({ port: 3000 })
})()
