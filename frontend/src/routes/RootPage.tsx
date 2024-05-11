import { ABLY_APTOS_COUNTER_CHANNEL_NAME } from "@/common"
import CounterLogo from "@/icons/CounterLogo"
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design"
import { ChannelProvider } from "ably/react"
import { Flex, Layout } from "antd"
import { Link, Outlet } from "react-router-dom"

const { Content, Header } = Layout

export default function RootPage() {
  return (
    <Layout style={{ height: "100vh" }}>
      <Header style={{ padding: "15px" }}>
        <Flex style={{ height: "100%" }}
          justify="space-between"
          align="center">
          <Link to={"/"}>
            <CounterLogo style={{ width: "32px", fill: "white " }} />
          </Link>
          <WalletSelector />
        </Flex>
      </Header>
      <Content style={{ display: "flex", flexDirection: "column" }}>
        <ChannelProvider channelName={ABLY_APTOS_COUNTER_CHANNEL_NAME}>
          <Outlet />
        </ChannelProvider >
      </Content>
    </Layout>
  )
}
