module Symbols
  extend ActiveSupport::Concern

  class_methods do
    def symbols(provider: :binance)
      case provider
      when :binance
        Coins::BinanceCoinFetcher.new.fetch_coins
      else
        raise "Invalid provider: #{provider}"
      end
    end
  end
end
