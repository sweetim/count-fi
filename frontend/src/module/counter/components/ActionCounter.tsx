import { Button, Flex, Typography } from "antd"
import { FC, useEffect, useState } from "react"
import { PlusIcon, MinusIcon } from "@heroicons/react/20/solid"

import { decrementTransactionData, getValue, incrementTransactionData } from "../contract"
import { useWallet } from "@aptos-labs/wallet-adapter-react"
import { getAptosClient } from "@/common/aptosClient"

const { Title } = Typography

const aptos = getAptosClient()

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

  return (
    <Flex
      justify="center"
      align="center"
      gap="small"
      vertical
      style={{ height: "100%", width: "100%", paddingTop: "20px", paddingBottom: "20px" }}>
      <Button type="text"
        icon={<PlusIcon
          width={32}
          height={32}
          color="#FFF" />}
        size={"large"}
        shape="circle"
        onClick={incrementClickHandler} />
      <Title style={{ fontSize: "8rem", margin: 0 }}>{value}</Title>
      <Button type="text"
        icon={<MinusIcon
          width={32}
          height={32}
          color="#FFF" />}
        size={"large"}
        shape="circle"
        onClick={decrementClickHandler} />
    </Flex>
  )
}

export default ActionCounter
