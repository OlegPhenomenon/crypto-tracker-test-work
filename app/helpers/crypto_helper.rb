module CryptoHelper
  COIN_CONFIGS = {
    'BTC' => { color: 'orange', name: 'Bitcoin', icon: '₿' },
    'ETH' => { color: 'blue', name: 'Ethereum', icon: 'Ξ' },
    'PYTH' => { color: 'purple', name: 'Pyth Network', icon: '⚡' },
    'ADA' => { color: 'indigo', name: 'Cardano', icon: '◈' },
    'BNB' => { color: 'yellow', name: 'BNB', icon: '◆' },
    'SOL' => { color: 'green', name: 'Solana', icon: '◉' },
    'XRP' => { color: 'blue', name: 'XRP', icon: '◊' },
    'DOT' => { color: 'pink', name: 'Polkadot', icon: '●' },
    'LINK' => { color: 'blue', name: 'Chainlink', icon: '⬡' }
  }.freeze

  def coin_config(symbol)
    coin_name = symbol.gsub(/USDT$/, '')
    COIN_CONFIGS[coin_name] || { color: 'gray', name: coin_name, icon: '◯' }
  end

  def coin_name(symbol)
    symbol.gsub(/USDT$/, '')
  end
end
