module Coins
  class BinanceCoinFetcher < CoinFetcherInterface
    def fetch_coins
      mock_coins
    end

    private

    def mock_coins
      %w[BTCUSDT ETHUSDT PYTHUSDT ADAUSDT BNBUSDT SOLUSDT XRPUSDT DOTUSDT LINKUSDT]
    end
  end
end
