import { FC } from "react"
import {
  Badge,
  Card,
} from "antd"
import { CollectionMetadata } from "@/contract"

const { Meta } = Card

const CollectionCard: FC<CollectionMetadata> = (props) => {
  return (
    <Card
      className="min-h-72"
      hoverable
      title={props.name}
      extra={<Badge count={props.max_supply} color="#fffb8f" overflowCount={1000000} />}
      cover={
        <img
          className="max-h-32 min-h-32 !rounded-none"
          alt={props.description}
          src={props.uri}
        />
      }
    >
      <Meta description={props.description} />
    </Card>
  )
}

export default CollectionCard
