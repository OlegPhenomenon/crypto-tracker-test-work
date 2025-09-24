import { Controller } from "@hotwired/stimulus";
import { createConsumer } from "@rails/actioncable";

export default class extends Controller {
  static targets = ["pricesList"];

  connect() {
    console.log("PricesController connected");

    this.consumer = createConsumer();

    const symbols = ["BTCUSDT", "ETHUSDT", "PYTHUSDT", "ADAUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT", "DOTUSDT", "LINKUSDT"];

    symbols.forEach(symbol => {
      this.consumer.subscriptions.create({ channel: "PriceChannel", symbol: symbol }, {
      connected() {
        console.log("PriceChannel connected");
      },
      disconnected() {
        console.log("PriceChannel disconnected");
      },
      received(data) {
        const priceElement = document.getElementById(`${symbol}-price`);
        if (priceElement) {
          priceElement.innerText = data.price;
        }
      },
      });
    });
  }
}
