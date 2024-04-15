import { FC } from "react"
import { CounterAction, CounterRecord } from "../contract"
import { Avatar, List } from "antd"
import { formatDistanceToNow } from "date-fns"
import { PlusIcon, MinusIcon, QuestionMarkCircleIcon } from "@heroicons/react/20/solid"

export type TimelineProps = {
  records: CounterRecord[]
}

const getActionIcon = (action: CounterAction) => {
  const ACTION_ICONS: Record<number, JSX.Element> = {
    1: <PlusIcon className="fill-lime-300" />,
    2: <MinusIcon className="fill-rose-500" />,
    3: <QuestionMarkCircleIcon className="fill-rose-500" />,
  }

  return ACTION_ICONS[action]
}

const Timeline: FC<TimelineProps> = ({ records }) => {
  return (
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
  )
}

export default Timeline
