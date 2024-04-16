import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { ConfigProvider, theme } from 'antd'
import { AptosWalletAdapterProvider } from '@aptos-labs/wallet-adapter-react'
import { PetraWallet } from 'petra-plugin-wallet-adapter'

import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";

const wallets = [
  new PetraWallet()
]

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AptosWalletAdapterProvider
      plugins={wallets}
      autoConnect={true}>
      <ConfigProvider theme={{
        algorithm: theme.darkAlgorithm,
        token: {
          fontFamily: "mali",
        },
        components: {
          Layout: {
            headerBg: "#192435",
            bodyBg: "#1e293b"
          },
          Timeline: {
            dotBg: "#1e293b"
          }
        }
      }}>
        <App />
      </ConfigProvider>
    </AptosWalletAdapterProvider>
  </React.StrictMode>,
)
