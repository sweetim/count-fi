import React, { useEffect, useState } from 'react';

import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";

import { Aptos, AptosConfig, MoveValue, Network } from '@aptos-labs/ts-sdk';
import { InputTransactionData, useWallet } from '@aptos-labs/wallet-adapter-react';
import { Button, Layout, Flex, Avatar, List } from 'antd';
import { Content, Footer, Header } from 'antd/es/layout/layout';
import { formatDistanceToNow } from "date-fns"
import { PlusIcon, MinusIcon, QuestionMarkCircleIcon } from "@heroicons/react/20/solid"
import { error } from 'console';

const aptosConfig = new AptosConfig({ network: Network.DEVNET });
const aptos = new Aptos(aptosConfig);

const MODULE_ADDRESS = "0x94c652e656ed7d99fbd44905504244be44a361b3e04abf8b5b0c342ae74ca25a"

type CounterRecord = {
  timestamp_us: string,
  user: string,
  action: number
}

function App() {
  const [records, setRecords] = useState<CounterRecord[]>([])
  const [value, setValue] = useState("...");

  const { account, signAndSubmitTransaction } = useWallet()

  useEffect(() => {
    const getAllRecords = async () => {
      try {
        const [allRecords] = await aptos.view<CounterRecord[][]>({
          payload: {
            function: `${MODULE_ADDRESS}::counter::query_all_records`,
          }
        })
        allRecords.sort((a, b) => Number(b.timestamp_us) - Number(a.timestamp_us))
        setRecords(allRecords)

        console.log(allRecords)
      } catch (e) {
        console.log(e)
      }
    }

    const getValue = async () => {
      try {
        const [value] = await aptos.view<CounterRecord[][]>({
          payload: {
            function: `${MODULE_ADDRESS}::counter::get_value`,
          }
        })

        setValue(value.toString())
      } catch (e) {
        console.log(e)
      }
    }

    // if (!account) return;

    getValue()
    getAllRecords()
  }, [])


  const getActionIcon = (action: number) => {
    const ACTION_ICONS: Record<number, JSX.Element> = {
      1: <PlusIcon className="fill-lime-300" />,
      2: <MinusIcon className="fill-rose-500" />,
      3: <QuestionMarkCircleIcon className="fill-rose-500" />,
    }

    return ACTION_ICONS[action]
  }

  async function decrementClickHandler() {
    if (!account) return;
    console.log(account.address)

    const transaction: InputTransactionData = {
      data: {
        function: `${MODULE_ADDRESS}::counter::decrement`,
        functionArguments: []
      }
    }

    try {
      const response: any = await signAndSubmitTransaction(transaction)
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  async function incrementClickHandler() {
    const transaction: InputTransactionData = {
      data: {
        function: `${MODULE_ADDRESS}::counter::increment`,
        functionArguments: []
      }
    }

    try {
      const response: any = await signAndSubmitTransaction(transaction)
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  return (
    <Flex gap="middle" wrap="wrap">
      <Layout>
        <Header>
          <WalletSelector />
        </Header>
        <Content>
          <Button type="primary" shape="circle" size="large" onClick={decrementClickHandler}>-</Button>
          <h1>{value}</h1>
          <Button type="primary" shape="circle" size="large" onClick={incrementClickHandler}>+</Button>
        </Content>
        <Content>
          <List
            itemLayout="horizontal"
            dataSource={records}
            renderItem={(item, index) => (
              <List.Item>
                <List.Item.Meta
                  avatar={<Avatar src={getActionIcon(item.action)} />}
                  title={<a href={`https://explorer.aptoslabs.com/account/${item.user}?network=devnet`}>{item.user}</a>}
                  description={formatDistanceToNow(Number(item.timestamp_us) / 1000)}
                />
              </List.Item>
            )}
          />
        </Content>
      </Layout>
    </Flex>
  );
}

export default App;
