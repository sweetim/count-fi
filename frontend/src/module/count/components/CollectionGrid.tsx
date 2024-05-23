import {
  Col,
  Row,
} from "antd"
import { FC } from "react"
import {
  CollectionMetadata,
  getCollectionId,
} from "@/contract"
import { Link } from "react-router-dom"

import CollectionCard from "./CollectionCard"

type CollectionGridProps = {
  items: CollectionMetadata[]
  className?: string
}

const CollectionGrid: FC<CollectionGridProps> = ({ className, items }) => {
  const renderCollectionCols = () => {
    return items.map(item => {
      return (
        <Col
          key={item.name}
          className="gutter-row p-1"
          xs={{ flex: "100%" }}
          sm={{ flex: "50%" }}
          md={{ flex: "33%" }}
        >
          <Link to={`/collection/${getCollectionId(item.name)}`}>
            <CollectionCard {...item} />
          </Link>
        </Col>
      )
    })
  }

  return (
    <Row className={`sm:w-full md:w-2/3 ${className}`} gutter={{ xs: 8, sm: 16, md: 24, lg: 32 }}>
      {renderCollectionCols()}
    </Row>
  )
}

export default CollectionGrid
