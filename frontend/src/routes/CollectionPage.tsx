import CollectionGrid from "@/module/count/components/CollectionGrid";
import { CountCollectionItem, getAllCollection } from "@/module/count/contract";
import ParticlesLogo from "@/module/tsparticle/ParticlesLogo";
import { Flex } from "antd";
import { useEffect, useState } from "react";

export default function CollectionPage() {
  const [ countCollectionItems, setCountCollectionItems ] = useState<CountCollectionItem[]>([])

  useEffect(() => {
    getAllCollection().then(res => setCountCollectionItems(res))
  }, [])

  return (
    <Flex
      justify="center"
      align="center"
      gap="small"
      vertical
      className="h-full w-full">
      <div className="h-1/3 w-1/3">
        <div className="h-2/3">
          <ParticlesLogo />
        </div>
        <div className="text-center">
          <h1 className="text-6xl p-3">
            CountFI
          </h1>
          <p>count to mint a NFT</p>
          {/* <p></p> */}
          <p>each NFT collection is limited by the mathematical properties, this creates an intrinsic value for each minted NFT through collaboration of many users to achieve that count together</p>
        </div>
      </div>
      <div className="mt-20 flex items-center justify-center">
        <CollectionGrid items={countCollectionItems} />
      </div>
    </Flex>
  )
}

