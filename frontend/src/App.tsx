import { WalletSelector } from '@aptos-labs/wallet-adapter-ant-design';
import { Col, Flex, Grid, Layout, Row } from 'antd'
import { Content, Header } from 'antd/es/layout/layout'
import { FC, useEffect, useState } from 'react'
import { CounterRecord, CounterRecordEvent, getAllRecords, getValue } from './module/counter/contract';
import { ActionCounter, RecordTimeline } from './module/counter/components';
import CounterLogo from './icons/CounterLogo';
import { ChannelProvider, useChannel } from 'ably/react';
import { ABLY_APTOS_COUNTER_CHANNEL_NAME } from './common';

const { useBreakpoint } = Grid;

const CounterApp: FC = () => {
  const [value, setValue] = useState("...")
  const [allRecords, setAllRecords] = useState<CounterRecord[]>([])

  useEffect(() => {
    getValue().then(v => setValue(v.toString()))
  }, [])

  useEffect(() => {
    getAllRecords().then(result => setAllRecords(result))
  }, [])

  useChannel(
    ABLY_APTOS_COUNTER_CHANNEL_NAME,
    (message) => {
      const data: CounterRecordEvent[] = message.data

      if (allRecords.length === 0) return;

      data.sort((a, b) => Number(b.timestamp_us) - Number(a.timestamp_us))

      const latestData = data.filter(({ timestamp_us }) => timestamp_us > allRecords[0].timestamp_us)

      if (latestData.length === 0) return;

      setAllRecords(prev => [...latestData, ...prev])
      setValue(latestData[0].value)
    });

  const screens = useBreakpoint()

  const renderMobile = () => {
    const getHeight = allRecords.length === 0 ? "100%" : "auto"

    return (
      <>
        <Row style={{ paddingTop: "0.5rem", paddingBottom: "0.5rem", height: `${getHeight}` }}>
          <ActionCounter value={value} />
        </Row>
        {allRecords.length > 0 && <Row style={{ height: "100%", overflow: "auto", padding: "20px" }}>
          <RecordTimeline records={allRecords} />
        </Row>}
      </>
    )
  }

  const renderDesktop = () => {
    return (
      <Row
        style={{ height: "100%" }}>
        <Col sm={{ flex: "auto" }}>
          <ActionCounter value={value} />
        </Col>
        {allRecords.length > 0 && <Col span={16}
          style={{ overflow: "auto", padding: "20px", height: "100%" }}>
          <RecordTimeline records={allRecords} />
        </Col>}
      </Row>
    )
  }

  return (
    <Layout style={{ height: "100vh" }}>
      <Header style={{ padding: "15px" }}>
        <Flex style={{ height: "100%" }}
          justify="space-between"
          align="center">
          <CounterLogo style={{ width: "32px", fill: "white " }} />
          <WalletSelector />
        </Flex>
      </Header>
      <Content style={{ display: "flex", flexDirection: "column" }}>
        {screens.xs ? renderMobile() : renderDesktop()}
      </Content>
    </Layout>
  )
}

const App: FC = () => {
  return (
    <ChannelProvider channelName={ABLY_APTOS_COUNTER_CHANNEL_NAME}>
      <CounterApp />
    </ChannelProvider >
  )
}

export default App
