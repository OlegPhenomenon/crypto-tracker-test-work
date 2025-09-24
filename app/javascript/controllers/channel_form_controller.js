import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "formFrame"]

  connect() {
    console.log("ChannelFormController connected")
    this.loadInitialForm()
  }

  typeChanged(event) {
    const selectedType = event.target.value
    if (selectedType) {
      this.loadFormForType(selectedType)
    } else {
      this.clearForm()
    }
  }

  loadInitialForm() {
    if (this.hasSelectTarget) {
      const selectedType = this.selectTarget.value
      if (selectedType) {
        this.loadFormForType(selectedType)
      }
    }
  }

  loadFormForType(channelType) {
    const url = `/notification_channels/form_fields?channel_type=${channelType}`

    fetch(url, {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      this.formFrameTarget.innerHTML = html
    })
    .catch(error => {
      console.error('Error loading form:', error)
      this.clearForm()
    })
  }

  clearForm() {
    this.formFrameTarget.innerHTML = '<div class="text-gray-500 text-center py-8">Select channel type for configuration</div>'
  }
}