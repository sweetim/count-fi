import { useEffect } from "react"
import { tsParticles } from "@tsparticles/engine"
import { loadPolygonMaskPlugin } from "@tsparticles/plugin-polygon-mask"
import { loadSlim } from "@tsparticles/slim"

import { POLYGON_MASK_LOGO_OPTIONS } from "./polygonMaskLogoOptions"
import { useLoadingStatus } from "@/store"

const ParticlesLogo = () => {
  const setTsParticleLoadingStatus = useLoadingStatus((state) => state.setTsParticleLoadingStatus)

  async function setup() {
    await loadPolygonMaskPlugin(tsParticles)
    await loadSlim(tsParticles)

    return await tsParticles.load({
      id: "tsparticles",
      options: POLYGON_MASK_LOGO_OPTIONS,
    })
  }

  useEffect(() => {
    setTsParticleLoadingStatus(true)
    setup().then(_ => {
      setTsParticleLoadingStatus(false)
    })
  }, [])

  return (
    <div className="h-full" id="tsparticles">
    </div>
  )
}

export default ParticlesLogo
