import { Button, Flex, Typography } from "antd"
import { CSSProperties, FC, useEffect, useState } from "react"
import { MinusOutlined, PlusOutlined } from "@ant-design/icons"

import { useWallet } from "@aptos-labs/wallet-adapter-react"
import { decrementTransactionData, getValue, incrementTransactionData, randomTransactionData } from "../contract"

import { getAptosClient } from "@/common/aptosClient"

const { Title } = Typography

const aptos = getAptosClient()

const actionButtonStyle: CSSProperties = {
  width: "48px",
  height: "48px"
}

const actionIconStyle: CSSProperties = {
  fontSize: "32px",
  color: "#FFF"
}

const ActionCounter: FC = () => {
  const { signAndSubmitTransaction, account } = useWallet()
  const [value, setValue] = useState("...")

  useEffect(() => {
    getValue().then(v => setValue(v.toString()))
  }, [])

  async function incrementClickHandler() {
    if (!account) throw new Error("account not available")

    try {
      const response: any = await signAndSubmitTransaction(incrementTransactionData())
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  async function decrementClickHandler() {
    if (!account) throw new Error("account not available")

    try {
      const response: any = await signAndSubmitTransaction(decrementTransactionData())
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  async function randomClickHandler() {
    console.log("here")
    if (!account) throw new Error("account not available")

    try {
      const response: any = await signAndSubmitTransaction(randomTransactionData())
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  return (
    <Flex
      justify="center"
      align="center"
      gap="small"
      vertical
      style={{ height: "100%", width: "100%" }}>
      <Button type="text"
        style={actionButtonStyle}
        icon={<PlusOutlined
          style={actionIconStyle} />}
        shape="circle"
        onClick={incrementClickHandler} />
      <Title style={{ fontSize: "8rem", margin: 0, cursor: "pointer" }} onClick={randomClickHandler}>{value}</Title>
      <Button type="text"
        style={actionButtonStyle}
        icon={<MinusOutlined
          style={actionIconStyle} />}
        shape="circle"
        onClick={decrementClickHandler} />
    </Flex>
  )
}

export default ActionCounter
