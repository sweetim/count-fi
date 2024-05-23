import { create } from "zustand"
import { immer } from "zustand/middleware/immer"

type LoadingStatusState = {
  isTsParticleLoading: boolean
}

type LoadingStatusAction = {
  setTsParticleLoadingStatus: (status: boolean) => void
}

export const useLoadingStatus = create<LoadingStatusState & LoadingStatusAction>()(
  immer((set) => ({
    isTsParticleLoading: true as boolean,
    setTsParticleLoadingStatus: (status: boolean) =>
      set((state) => {
        state.isTsParticleLoading = status
      }),
  })),
)
