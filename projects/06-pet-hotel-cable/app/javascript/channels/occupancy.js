import consumer from "channels/consumer"

consumer.subscriptions.create("OccupancyChannel", {
  received(data) {
    const root = document.getElementById("occupancy-live")
    if (root && data.html) root.innerHTML = data.html
  }
})
