import {
  Avatar,
  Badge,
  Button,
  Flex,
  Space,
  Typography,
} from "antd"
import {
  CSSProperties,
  FC,
  useEffect,
  useState,
} from "react"
import {
  MinusOutlined,
  PlusOutlined,
} from "@ant-design/icons"
import { useWallet } from "@aptos-labs/wallet-adapter-react"

import {
  decrementTransactionData,
  getNextValue,
  incrementTransactionData,
  randomTransactionData,
} from "@/contract"
import { getAptosClient } from "@/common/aptosClient"
import { useLoaderData } from "react-router-dom"

const { Title, Text } = Typography

const aptos = getAptosClient()

const actionButtonStyle: CSSProperties = {
  width: "48px",
  height: "48px",
}

const actionIconStyle: CSSProperties = {
  fontSize: "32px",
  color: "#FFF",
}
export type ActionCounterProps = {
  value: string
}

type CoinsData = {
  name: string
  symbol: string
  iconUri: string
  amount: number
  decimals: number
}
const ActionCounter: FC<ActionCounterProps> = ({ value }) => {
  const { collectionTypeId } = useLoaderData() as { collectionTypeId: string }
  const { signAndSubmitTransaction, account } = useWallet()
  const [coinsData, setCoinsData] = useState<CoinsData[]>([])

  const [nextValue, setNextValue] = useState("...")

  useEffect(() => {
    getNextValue(collectionTypeId).then((v: any) => setNextValue(v.toString()))
  }, [value])

  async function incrementClickHandler() {
    if (!account) return

    try {
      const response: any = await signAndSubmitTransaction(incrementTransactionData(collectionTypeId))
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  async function decrementClickHandler() {
    if (!account) return

    try {
      const response: any = await signAndSubmitTransaction(decrementTransactionData(collectionTypeId))
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  async function randomClickHandler() {
    if (!account) return

    try {
      const response: any = await signAndSubmitTransaction(randomTransactionData(collectionTypeId))
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  const countLeftToMint = Math.abs(Number(nextValue) - Number(value))
  const countLeftToMintText = Number.isNaN(countLeftToMint)
    ? "..."
    : countLeftToMint === 0
    ? 1
    : countLeftToMint.toString()

  async function getTokenBalance() {
    if (!account) return

    const coinsData = await aptos.account.getAccountCoinsData({
      accountAddress: account?.address,
    })

    setCoinsData(
      coinsData.map(data => ({
        name: data.metadata?.name || "",
        symbol: data.metadata?.symbol || "",
        iconUri: data.metadata?.icon_uri || "/aptos.svg",
        amount: data.amount,
        decimals: data.metadata?.decimals || 0,
      })).filter(({ symbol }) => symbol.includes("APT") || symbol.includes("CNT"))
        .filter(({ amount }) => amount > 0)
        .slice(0, 2),
    )
  }

  useEffect(() => {
    getTokenBalance().then(console.log)
  }, [account])

  return (
    <Flex
      justify="center"
      align="center"
      gap="small"
      vertical
    >
      {account && (
        <Button
          type="text"
          style={actionButtonStyle}
          icon={
            <PlusOutlined
              style={actionIconStyle}
            />
          }
          shape="circle"
          onClick={incrementClickHandler}
        />
      )}
      <Title
        className={`!text-9xl !m-1 ${account ? "cursor-pointer" : "cursor-default"}`}
        onClick={randomClickHandler}
      >
        {value}
      </Title>
      {account && (
        <Button
          type="text"
          style={actionButtonStyle}
          icon={
            <MinusOutlined
              style={actionIconStyle}
            />
          }
          shape="circle"
          onClick={decrementClickHandler}
        />
      )}
      <Text>
        <Badge
          style={{ background: "#fffb8f", marginRight: "5px" }}
          count={countLeftToMintText}
          overflowCount={100000}
        />
        {`count left to mint a NFT`}
      </Text>
      {account && (
        <Space size="middle" className="mt-2">
          {coinsData.map((data, i) => (
            <div key={i} className="bg-slate-700 text-[#1e293b] flex flex-row p-3 rounded-lg items-center">
              <Space size="middle">
                <Avatar className="text-slate-800" src={data.iconUri}></Avatar>
                <p className="text-xl text-white">
                  {(data.amount / Math.pow(10, data.decimals)).toFixed(data.decimals > 0 ? 2 : 0)}
                </p>
              </Space>
            </div>
          ))}
        </Space>
      )}
    </Flex>
  )
}

export default ActionCounter
