import { WalletSelector } from '@aptos-labs/wallet-adapter-ant-design';
import { Col, Flex, Layout, Row } from 'antd'
import { Content, Header } from 'antd/es/layout/layout'
import { FC, useEffect, useState } from 'react'
import { CounterRecord, getAllRecords } from './module/counter/contract';
import { ActionCounter, RecordTimeline } from './module/counter/components';
import CounterLogo from './icons/CounterLogo';

const App: FC = () => {
  const [allRecords, setAllRecords] = useState<CounterRecord[]>([])

  useEffect(() => {
    getAllRecords().then(result => setAllRecords(result))
  }, [])

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
      <Content>
        <Row
          style={{ height: "100%" }}>
          <Col
            xs={24}
            md={8}>
            <ActionCounter />
          </Col>
          <Col xs={24}
            md={16}
            style={{ overflow: "auto", padding: "20px", height: "100%" }}>
            <RecordTimeline records={allRecords} />
          </Col>
        </Row>
      </Content>
    </Layout>
  )
}

export default App
