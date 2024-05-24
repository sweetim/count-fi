import { Flex } from "antd"
import {
  FC,
  ReactElement,
} from "react"

type CenterDivProps = {
  className?: string
  children: ReactElement | ReactElement[]
}

const CenterDiv: FC<CenterDivProps> = ({ children, className }) => {
  return (
    <Flex
      justify="center"
      align="center"
      gap="small"
      vertical
      className={`w-full h-full ${className}`}
    >
      {children}
    </Flex>
  )
}

export default CenterDiv
