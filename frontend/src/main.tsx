import React from "react"
import ReactDOM from "react-dom/client"
import {
  ConfigProvider,
  theme,
  ThemeConfig,
} from "antd"
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react"
import { PetraWallet } from "petra-plugin-wallet-adapter"
import { PontemWallet } from "@pontem/wallet-adapter-plugin"
import { AblyProvider } from "ably/react"
import {
  createBrowserRouter,
  RouterProvider,
} from "react-router-dom"

import "./index.css"
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css"

import {
  CollectionPage,
  CollectionTypePage,
  RootPage,
} from "./routes"

import { getAblyClient } from "./common"

const wallets = [
  new PetraWallet(),
  new PontemWallet(),
]

const antThemeConfig: ThemeConfig = {
  algorithm: theme.darkAlgorithm,
  token: {
    fontFamily: "mali",
  },
  components: {
    Layout: {
      headerBg: "#192435",
      bodyBg: "#1e293b",
    },
    Timeline: {
      dotBg: "#1e293b",
    },
  },
}

const router = createBrowserRouter([
  {
    path: "/",
    element: <RootPage />,
    children: [
      {
        path: "/",
        element: <CollectionPage />,
      },
      {
        path: "/collection",
        element: <CollectionPage />,
      },
      {
        path: "collection/:collectionTypeId",
        element: <CollectionTypePage />,
        loader: async ({ params }) => {
          const { collectionTypeId } = params
          return {
            collectionTypeId,
          }
        },
      },
    ],
  },
])

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <AptosWalletAdapterProvider
      plugins={wallets}
      autoConnect={true}
    >
      <ConfigProvider theme={antThemeConfig}>
        <AblyProvider client={getAblyClient()}>
          <RouterProvider router={router} />
        </AblyProvider>
      </ConfigProvider>
    </AptosWalletAdapterProvider>
  </React.StrictMode>,
)
