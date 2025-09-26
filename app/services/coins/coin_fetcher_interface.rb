module Coins
  class CoinFetcherInterface
    def fetch_coins
      raise NotImplementedError, "#{self.class.name} must implement :fetch_coins"
    end
  end
end
