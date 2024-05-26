import {
  Avatar,
  Button,
  Col,
  Grid,
  Image,
  Row,
} from "antd"
import {
  FC,
  useEffect,
  useState,
} from "react"
import {
  CounterRecord,
  CounterRecordEvent,
  getAllRecords,
  getValue,
} from "../contract"
import {
  ActionCounter,
  RecordTimeline,
} from "../module/count/components"
import { useChannel } from "ably/react"
import {
  ABLY_APTOS_COUNTER_CHANNEL_NAME,
  getAptosClient,
} from "../common"
import { useLoaderData } from "react-router-dom"
import CenterDiv from "@/module/common/CenterDiv"
import {
  LeftOutlined,
  RightOutlined,
} from "@ant-design/icons"

const { useBreakpoint } = Grid

const CollectionTypePage: FC = () => {
  const { collectionTypeId } = useLoaderData() as { collectionTypeId: string }

  const [value, setValue] = useState("...")
  const [allRecords, setAllRecords] = useState<CounterRecord[]>([])

  useEffect(() => {
    getValue(collectionTypeId).then(v => setValue(v.toString()))
  }, [])

  useEffect(() => {
    ;(async () => {
      const aptos = getAptosClient()

      const allRecords = await getAllRecords(collectionTypeId)

      const uniqueUserAddress = [...new Set(allRecords.map(r => r.user))]
      const uniqueUserANS = await Promise.all(uniqueUserAddress.map(async (address) => {
        const ans = await aptos.ans.getPrimaryName({ address })

        return {
          ans: ans && `${ans}.apt`,
          address,
        }
      }))

      const ansLUT = uniqueUserANS.reduce((acc: any, a) => {
        return acc[a.address] = a.ans, acc
      }, {})

      const allRecordsWithAns = allRecords.map((record) => ({
        ...record,
        user: ansLUT[record.user] || record.user,
      }))

      setAllRecords(allRecordsWithAns)
    })()
  }, [])

  useChannel(
    ABLY_APTOS_COUNTER_CHANNEL_NAME,
    (message) => {
      const data: CounterRecordEvent[] = message.data

      if (allRecords.length === 0) return

      data.sort((a, b) => Number(b.timestamp_us) - Number(a.timestamp_us))

      const latestData = data.filter(({ timestamp_us }) => timestamp_us > allRecords[0].timestamp_us)

      if (latestData.length === 0) return

      setAllRecords(prev => [...latestData, ...prev])
      setValue(latestData[0].value)
    },
  )

  const screens = useBreakpoint()

  const renderMobile = () => {
    const getHeight = allRecords.length === 0 ? "100%" : "auto"

    return (
      <>
        <Row style={{ paddingTop: "0.5rem", paddingBottom: "0.5rem", height: `${getHeight}` }}>
          <ActionCounter value={value} />
        </Row>
        {allRecords.length > 0 && (
          <Row style={{ height: "100%", overflow: "auto", padding: "20px" }}>
            <RecordTimeline records={allRecords} />
          </Row>
        )}
      </>
    )
  }

  const renderDesktop = () => {
    const linearImages = Array(10).fill(0)
      .map((_, i) => {
        if (i < 2) return `/${i + 1}.png`

        return `https://placehold.jp/fefb9d/1e293b/200x384.png?text=?`
      })
      .map((uri, i) => {
        const className = i === 2
          ? "border-[#fefb9d] border-t-4 border-2"
          : ""

        const labelDiv = () => {
          const timestamp = [
            "5/23/2024, 10:47:12 PM",
            "5/23/2024, 10:47:19 PM",
          ]

          const valueDiv = () => {
            const valueText = i < 2
              ? <Avatar size={24} className="bg-slate-700">{i}</Avatar>
              : i === 2
              ? (
                <div className="bg-slate-700 p-1 px-3 rounded-full text-xs">
                  <p>1 count left to mint this NFT</p>
                </div>
              )
              : ""
            return (
              <div className="absolute top-2 left-2 rounded-full">
                {valueText}
              </div>
            )
          }

          return (
            <>
              {i < 2
                ? (
                  <div className="absolute bottom-2 left-2 rounded-lg bg-slate-700 p-2">
                    <h2 className="text-sm">hosweetim.apt</h2>
                    <p className="text-xs font-thin text-gray-300">{timestamp[i]}</p>
                  </div>
                )
                : ""}
              {valueDiv()}
            </>
          )
        }

        return (
          <div className="relative">
            <Image
              className={className}
              height={384}
              width={200}
              src={uri}
            />
            {labelDiv()}
          </div>
        )
      })

    const fibonacciImages = Array(10).fill(0)
      .map((_, i) => {
        if (i < 2) return `/0_${i}.webp`

        return `https://placehold.jp/fefb9d/1e293b/250x250.png?text=?`
      })
      .map((uri, i) => {
        const className = i === 2
          ? "border-[#fefb9d] border-t-4 border-2"
          : ""

        const labelDiv = () => {
          const timestamp: any = {
            0: [
              "5/23/2024, 10:43:41 PM",
              "5/23/2024, 10:43:52 PM",
            ],
            1: [],
            2: [
              "5/23/2024, 10:47:12 PM",
              "5/23/2024, 10:47:19 PM",
            ],
          }

          const valueDiv = () => {
            const valueText = i < 2
              ? (
                <Avatar size={24} className="bg-slate-700">
                  {collectionTypeId === "2" ? 0 : collectionTypeId === "0" ? i : 0}
                </Avatar>
              )
              : i === 2
              ? (
                <div className="bg-slate-700 p-1 px-3 rounded-full text-xs">
                  <p>1 count left to mint this NFT</p>
                </div>
              )
              : ""
            return (
              <div className="absolute top-2 left-2 rounded-full">
                {valueText}
              </div>
            )
          }

          return (
            <>
              {i < 2
                ? (
                  <div className="absolute bottom-2 left-2 rounded-lg bg-slate-700 p-2">
                    <h2 className="text-sm">hosweetim.apt</h2>
                    <p className="text-xs font-thin text-gray-300">{timestamp[collectionTypeId][i]}</p>
                  </div>
                )
                : ""}
              {valueDiv()}
            </>
          )
        }

        return (
          <div className="relative">
            <Image
              className={className}
              height={collectionTypeId === "2" ? 384 : collectionTypeId === "0" ? 250 : 250}
              width={collectionTypeId === "2" ? 200 : collectionTypeId === "0" ? 250 : 250}
              src={uri}
            />
            {labelDiv()}
          </div>
        )
      })

    const primeNumberImages = Array(10).fill(0)
      .map((_, i) => {
        if (i < 3) return `/1_${i}.png`

        return `https://placehold.jp/fefb9d/1e293b/250x320.png?text=?`
      })
      .map((uri, i) => {
        const className = i === 2
          ? "border-[#fefb9d] border-t-4 border-2"
          : ""

        const labelDiv = () => {
          const timestamp = [
            "5/26/2024, 11:49:33 AM",
            "5/26/2024, 11:49:37 AM",
            "5/26/2024, 11:50:19 AM",
          ]

          const text = ["2", "3", "5"]
          const valueDiv = () => {
            const valueText = i < 3
              ? (
                <Avatar size={24} className="bg-slate-700">
                  {text[i]}
                </Avatar>
              )
              : i === 3
              ? (
                <div className="bg-slate-700 p-1 px-3 rounded-full text-xs">
                  <p>1 count left to mint this NFT</p>
                </div>
              )
              : ""
            return (
              <div className="absolute top-2 left-2 rounded-full">
                {valueText}
              </div>
            )
          }

          return (
            <>
              {i < 3
                ? (
                  <div className="absolute bottom-2 left-2 rounded-lg bg-slate-700 p-2">
                    <h2 className="text-sm">hosweetim.apt</h2>
                    <p className="text-xs font-thin text-gray-300">{timestamp[i]}</p>
                  </div>
                )
                : ""}
              {valueDiv()}
            </>
          )
        }

        return (
          <div className="relative">
            <Image
              className={className}
              height={320}
              width={250}
              src={uri}
            />
            {labelDiv()}
          </div>
        )
      })

    return (
      <Row className="h-full">
        <Col sm={{ flex: "auto" }}>
          <CenterDiv>
            <ActionCounter value={value} />
            <div className="flex flex-row">
              <Button icon={<LeftOutlined />} className="border-none h-full bg-[#1e293b]" />
              <div className=" h-full max-w-xl overflow-auto mt-2">
                <div className="flex flex-row min-w-[2500px]">
                  {collectionTypeId === "0" ? fibonacciImages : ""}
                  {collectionTypeId === "1" ? primeNumberImages : ""}
                  {collectionTypeId === "2" ? linearImages : ""}
                </div>
              </div>
              <Button
                icon={<RightOutlined />}
                className="border-none h-full bg-[#1e293b]"
              />
            </div>
          </CenterDiv>
        </Col>

        {allRecords.length > 0 && (
          <Col span={12} className="overflow-auto p-5 h-full">
            <RecordTimeline records={allRecords} />
          </Col>
        )}
      </Row>
    )
  }

  return (
    <>
      {screens.xs ? renderMobile() : renderDesktop()}
    </>
  )
}

export default CollectionTypePage
