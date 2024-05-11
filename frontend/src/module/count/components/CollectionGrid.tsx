import { Col, Row } from "antd"
import { FC } from "react"
import { CountCollectionItem } from "../contract"
import CollectionCard from "./CollectionCard"
import { Link } from "react-router-dom"

type CollectionGridProps = {
  items: CountCollectionItem[]
  className?: string
}

const CollectionGrid: FC<CollectionGridProps> = ({ className, items }) => {
  const renderCollectionCols = () => {
    return items.map(item => {
      return (
        <Col key={item.name} className="gutter-row" span={8}>
            <Link to={`collection/${item.name}`}>
            <CollectionCard {...item} />
        </Link>
          </Col>
      )
    })
  }

  return (
    <Row className={`w-2/3 ${className}`} gutter={{ xs: 32, sm: 32, md: 32, lg: 32 }}>
      {renderCollectionCols()}
    </Row>
  )
}

export default CollectionGrid
