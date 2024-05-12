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
        <Col key={item.name} className="gutter-row p-1"
          xs={{ flex: '100%' }}
          sm={{ flex: '50%' }}
          md={{ flex: '33%' }}>
          <Link to={`collection/${item.name}`}>
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
