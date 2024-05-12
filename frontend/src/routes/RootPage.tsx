import { ABLY_APTOS_COUNTER_CHANNEL_NAME } from "@/common"
import CounterLogo from "@/icons/CounterLogo"
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design"
import { ChannelProvider } from "ably/react"
import { Flex, Layout } from "antd"
import { Link, Outlet } from "react-router-dom"

const { Content, Header } = Layout

export default function RootPage() {
  return (
    <Layout className="h-screen">
      <Header className="p-5">
        <Flex className="h-full"
          justify="space-between"
          align="center">
          <Link to={"/"}>
            <CounterLogo className="w-8 fill-white" />
          </Link>
          <WalletSelector />
        </Flex>
      </Header>
        <Content>
          <ChannelProvider channelName={ABLY_APTOS_COUNTER_CHANNEL_NAME}>
            <Outlet />
          </ChannelProvider >
        </Content>
    </Layout>
  )
}
