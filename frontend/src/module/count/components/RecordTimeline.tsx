import { FC } from "react"
import {
  Grid,
  Space,
  Timeline,
  TimelineItemProps,
  Typography,
} from "antd"
import {
  MinusCircleOutlined,
  PlusCircleOutlined,
  QuestionCircleOutlined,
} from "@ant-design/icons"
import { formatDistanceToNow } from "date-fns"

import {
  CounterAction,
  CounterRecord,
} from "@/contract"
import { getAptosExplorerUrl } from "@/common/aptosClient"

export type RecordTimelineProps = {
  records: CounterRecord[]
}

const { Text, Link } = Typography
const { useBreakpoint } = Grid

const RecordTimeline: FC<RecordTimelineProps> = ({ records }) => {
  const recordTemplate = (record: CounterRecord) => {
    const addressUrl = getAptosExplorerUrl(record.user)
    const timestamp_ms = Number(record.timestamp_us) / 1000
    const relativeTime = `${formatDistanceToNow(timestamp_ms)} ago`
    const timestampText = (new Date(timestamp_ms)).toLocaleString()

    return (
      <>
        <Space.Compact direction="vertical">
          <Link href={addressUrl} target="_blank" style={{ color: "white" }}>
            {record.user}
          </Link>
          <Text type="secondary">{relativeTime}</Text>
          <Text style={{ color: "#585f6b" }}>{timestampText}</Text>
        </Space.Compact>
      </>
    )
  }

  // const getPosition = (action: CounterAction) => {
  //   switch (action) {
  //     case CounterAction.Increment: return "left";
  //     case CounterAction.Decrement: return "right";
  //     case CounterAction.Random: return Math.floor(Math.random() * 2) ? "left" : "right";
  //   }
  // }

  const getActionIcon = (action: CounterAction) => {
    const ACTION_ICONS: Record<CounterAction, JSX.Element> = {
      1: <PlusCircleOutlined style={{ color: "#bef264" }} />,
      2: <MinusCircleOutlined style={{ color: "#f43f5e" }} />,
      3: <QuestionCircleOutlined spin style={{ color: "cyan" }} />,
    }

    return ACTION_ICONS[action]
  }

  const timelineItems = records.map<TimelineItemProps>(record => ({
    // position: getPosition(record.action),
    dot: getActionIcon(record.action),
    children: recordTemplate(record),
  }))

  const screens = useBreakpoint()
  const mode = screens.xs ? "left" : "alternate"

  return <Timeline mode={mode} items={timelineItems} />
}

export default RecordTimeline
