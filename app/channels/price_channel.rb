class PriceChannel < ApplicationCable::Channel
  def subscribed
    puts "🔔 Client subscribed to price_updates"
    stream_from "prices_for_#{params[:symbol]}"
  end

  def unsubscribed
    puts "🔕 Client unsubscribed from price_updates"
  end
end
