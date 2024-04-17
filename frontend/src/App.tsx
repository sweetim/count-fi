import { WalletSelector } from '@aptos-labs/wallet-adapter-ant-design';
import { Col, Flex, Grid, Layout, Row } from 'antd'
import { Content, Header } from 'antd/es/layout/layout'
import { FC, useEffect, useRef, useState } from 'react'
import { CounterRecord, getAllRecords } from './module/counter/contract';
import { ActionCounter, RecordTimeline } from './module/counter/components';
import CounterLogo from './icons/CounterLogo';

const { useBreakpoint } = Grid;

const App: FC = () => {
  const ref = useRef<HTMLDivElement>(null)
  const [ height, setHeight ] = useState(0)

  const [allRecords, setAllRecords] = useState<CounterRecord[]>([])

  useEffect(() => {
    getAllRecords().then(result => setAllRecords(result))
  }, [])

  const screens = useBreakpoint()
  useEffect(() => {
    setHeight(screens.xs && ref.current?.clientHeight || 0)
  }, [screens.xs, allRecords])

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
            ref={ref}
            xs={24}
            md={{ flex: "auto" }}
            style={{ paddingTop: "0.5rem", paddingBottom: "0.5rem"}}>
            <ActionCounter />
          </Col>
          {allRecords.length > 0 && <Col xs={24}
            md={16}
            style={{ overflow: "auto", padding: "20px", height: `calc(100% - ${height}px` }}>
            <RecordTimeline records={allRecords} />
          </Col>}
        </Row>
      </Content>
    </Layout>
  )
}

export default App
