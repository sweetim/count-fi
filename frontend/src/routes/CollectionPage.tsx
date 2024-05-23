import CollectionGrid from "@/module/count/components/CollectionGrid"
import {
  CollectionMetadata,
  getAllCollectionDescription,
} from "@/contract"
import ParticlesLogo from "@/module/tsparticle/ParticlesLogo"
import {
  useEffect,
  useState,
} from "react"

export default function CollectionPage() {
  const [countCollectionItems, setCountCollectionItems] = useState<CollectionMetadata[]>([])

  useEffect(() => {
    getAllCollectionDescription().then(res => setCountCollectionItems(res))
  }, [])

  return (
    <div className="h-full overflow-auto no-scrollbar p-5">
      <div className="flex items-center justify-center justify-items-center flex-col">
        <div className="h-96 sm:w-full md:w-1/3">
          <div className="h-2/3">
            <ParticlesLogo />
          </div>
          <div className="text-center">
            <h1 className="text-6xl p-3">
              CountFI
            </h1>
            <p>count to mint a NFT</p>
            {/* <p></p> */}
            <p>
              each NFT collection is limited by the mathematical properties, this creates an intrinsic value for each
              minted NFT through collaboration of many users to achieve that count together
            </p>
          </div>
        </div>
      </div>
      <div className="mt-20 flex items-center justify-center">
        <CollectionGrid items={countCollectionItems} />
      </div>
    </div>
  )
}
