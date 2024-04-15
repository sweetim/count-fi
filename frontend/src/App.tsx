import { WalletSelector } from '@aptos-labs/wallet-adapter-ant-design';
import { Flex, Layout } from 'antd'
import { Content, Header } from 'antd/es/layout/layout'
import { FC, useEffect, useState } from 'react'
import { CounterRecord, getAllRecords } from './module/contract';
import { ActionCounter, Timeline } from './module/components';


const App: FC = () => {
  const [ allRecords, setAllRecords ] = useState<CounterRecord[]>([])

  useEffect(() => {
    getAllRecords().then(result => setAllRecords(result))
  }, [])

  return (
    <Layout style={{ minHeight: "100vh" }}>
        <Header>
          <WalletSelector />
        </Header>
        <Content>
          <ActionCounter />
          <Timeline records={allRecords} />
        </Content>
      </Layout>
  )
}

export default App
