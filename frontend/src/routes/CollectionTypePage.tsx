import { Col, Grid, Row } from 'antd'
import { FC, useEffect, useState } from 'react'
import { CounterRecord, CounterRecordEvent, getAllRecords, getValue } from '../module/count/contract';
import { ActionCounter, RecordTimeline } from '../module/count/components';
import { useChannel } from 'ably/react';
import { ABLY_APTOS_COUNTER_CHANNEL_NAME, getAptosClient } from '../common';

const { useBreakpoint } = Grid;

const CollectionTypePage: FC = () => {
  const [value, setValue] = useState("...")
  const [allRecords, setAllRecords] = useState<CounterRecord[]>([])

  useEffect(() => {
    getValue().then(v => setValue(v.toString()))
  }, [])

  useEffect(() => {
    (async () => {
      const aptos = getAptosClient()

      const allRecords = await getAllRecords()

      const uniqueUserAddress = [...new Set(allRecords.map(r => r.user))]
      const uniqueUserANS = await Promise.all(uniqueUserAddress.map(async (address) => {
        const ans = await aptos.ans.getPrimaryName({ address })

        return {
          ans: ans && `${ans}.apt`,
          address
        }
      }))

      const ansLUT = uniqueUserANS.reduce((acc: any, a) => {
        return acc[a.address] = a.ans, acc
      }, {})

      const allRecordsWithAns = allRecords.map((record) => ({
        ...record,
        user: ansLUT[record.user] || record.user
      }))

      setAllRecords(allRecordsWithAns)
    })()
  }, [])

  useChannel(
    ABLY_APTOS_COUNTER_CHANNEL_NAME,
    (message) => {
      const data: CounterRecordEvent[] = message.data

      if (allRecords.length === 0) return;

      data.sort((a, b) => Number(b.timestamp_us) - Number(a.timestamp_us))

      const latestData = data.filter(({ timestamp_us }) => timestamp_us > allRecords[0].timestamp_us)

      if (latestData.length === 0) return;

      setAllRecords(prev => [...latestData, ...prev])
      setValue(latestData[0].value)
    });

  const screens = useBreakpoint()

  const renderMobile = () => {
    const getHeight = allRecords.length === 0 ? "100%" : "auto"

    return (
      <>
        <Row style={{ paddingTop: "0.5rem", paddingBottom: "0.5rem", height: `${getHeight}` }}>
          <ActionCounter value={value} />
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
        className="h-full">
        <Col sm={{ flex: "auto" }}>
          <ActionCounter value={value} />
        </Col>
        {allRecords.length > 0 && <Col span={16}
          className="overflow-auto p-5 h-full">
          <RecordTimeline records={allRecords} />
        </Col>}
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
