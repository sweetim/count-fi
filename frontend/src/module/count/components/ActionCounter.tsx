import {
  Badge,
  Button,
  Flex,
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

const ActionCounter: FC<ActionCounterProps> = ({ value }) => {
  const { collectionTypeId } = useLoaderData() as { collectionTypeId: string }
  const { signAndSubmitTransaction, account } = useWallet()

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

  return (
    <Flex
      justify="center"
      align="center"
      gap="small"
      vertical
      className="h-full w-full"
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
    </Flex>
  )
}

export default ActionCounter
