import { WalletSelector } from '@aptos-labs/wallet-adapter-ant-design';
import { Col, Flex, Grid, Layout, Row } from 'antd'
import { Content, Header } from 'antd/es/layout/layout'
import { FC, useEffect, useState } from 'react'
import { CounterRecord, getAllRecords } from './module/counter/contract';
import { ActionCounter, RecordTimeline } from './module/counter/components';
import CounterLogo from './icons/CounterLogo';

const { useBreakpoint } = Grid;

const App: FC = () => {
  const [allRecords, setAllRecords] = useState<CounterRecord[]>([])

  useEffect(() => {
    getAllRecords().then(result => setAllRecords(result))
  }, [])

  const screens = useBreakpoint()

  const renderMobile = () => {
    const getHeight = allRecords.length === 0 ? "100%" : "auto"

    return (
      <>
        <Row style={{ paddingTop: "0.25rem", paddingBottom: "0.25rem", height: `${getHeight}` }}>
          <ActionCounter />
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
          <ActionCounter />
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
        { screens.xs ? renderMobile() : renderDesktop() }
      </Content>
    </Layout>
  )
}

export default App
