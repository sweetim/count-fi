import { FC } from "react"
import { Grid, Space, Timeline, TimelineItemProps, Typography } from "antd"
import { MinusCircleOutlined, PlusCircleOutlined, QuestionCircleOutlined } from "@ant-design/icons"
import { formatDistanceToNow } from "date-fns"

import { CounterAction, CounterRecord } from "../contract"

export type RecordTimelineProps = {
  records: CounterRecord[]
}

const { Text, Link } = Typography
const { useBreakpoint } = Grid;

const getActionIcon = (action: CounterAction) => {
  const ACTION_ICONS: Record<number, JSX.Element> = {
    1: <PlusCircleOutlined style={{ color: "#bef264" }} />,
    2: <MinusCircleOutlined style={{ color: "#bef264" }} />,
    3: <QuestionCircleOutlined spin style={{ color: "#f43f5e" }} />,
  }

  return ACTION_ICONS[action]
}

const RecordTimeline: FC<RecordTimelineProps> = ({ records }) => {
  const recordTemplate = (record: CounterRecord) => {
    const addressUrl = `https://explorer.aptoslabs.com/account/${record.user}?network=devnet`
    const timestamp_ms = Number(record.timestamp_us) / 1000
    const relativeTime = `${formatDistanceToNow(timestamp_ms)} ago`
    const timestampText = (new Date(timestamp_ms)).toLocaleString()

    return (
      <>
        <Space.Compact direction="vertical" >
          <Link href={addressUrl} target="_blank" style={{ color: "white" }}>
            {record.user}
          </Link>
          <Text type="secondary">{relativeTime}</Text>
          <Text style={{ color: "#585f6b" }}>{timestampText}</Text>
        </Space.Compact>
      </>
    )
  }

  const timelineItems = records.map<TimelineItemProps>(record => ({
    dot: getActionIcon(record.action),
    children: recordTemplate(record)
  }))

  const screens = useBreakpoint()

  const mode = screens.xs ? "left" : "alternate"

  return (
    <Timeline mode={mode} items={timelineItems} />
  )
}

export default RecordTimeline
