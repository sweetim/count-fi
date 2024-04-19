import { aptos } from "@aptos-labs/aptos-protos";
import { ChannelCredentials, Metadata } from "@grpc/grpc-js";
import { Realtime } from "ably"
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk"
import Fastify from "fastify";

import "dotenv/config"

const {
  GRPC_STREAM_API_KEY,
  ABLY_API_KEY
} = process.env

const GRPC_STREAM_ENDPOINT_URL = "grpc.devnet.aptoslabs.com:443"
const ABLY_APTOS_COUNTER_CHANNEL_NAME = "aptos-counter"
const APTOS_COUNTER_MODULE_ADDRESS = "0x6b2cf48e40e3b651c309dc444d0d094ed9c342089289c8bf50c4a5646271f20b"

const aptosClient = new Aptos(new AptosConfig({
  network: Network.TESTNET
}))

const client = new aptos.indexer.v1.RawDataClient(
  GRPC_STREAM_ENDPOINT_URL,
  ChannelCredentials.createSsl(),
  {
    // "grpc.keepalive_permit_without_calls": 1,
    "grpc.keepalive_time_ms": 1000,
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
          if (ev.typeStr?.includes(APTOS_COUNTER_MODULE_ADDRESS)) {
            await channel.publish(ev)
            console.log(ev)
          }
        }
      }

      stream.resume()
    })

    await fastify.listen({ port: 3000 })
})()
