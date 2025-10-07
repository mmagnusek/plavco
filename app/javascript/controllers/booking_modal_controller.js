import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking-modal"
export default class extends Controller {
  static targets = ["modal", "userSelect", "slotId"]

  open(event) {
    const slotId = event.target.dataset.slotId
    this.slotIdTarget.value = slotId
    this.modalTarget.classList.remove('hidden')
    this.userSelectTarget.value = ''
  }

  close() {
    this.modalTarget.classList.add('hidden')
    this.slotIdTarget.value = ''
  }

  confirm() {
    const userId = this.userSelectTarget.value
    const slotId = this.slotIdTarget.value

    if (!userId) {
      alert('Please select a user')
      return
    }

    if (!slotId) {
      alert('No slot selected')
      return
    }

    // Create form and submit via Turbo
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = `/slots/${slotId}/book?user_id=${userId}`
    form.style.display = 'none'

    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]')
    if (csrfToken) {
      const tokenInput = document.createElement('input')
      tokenInput.type = 'hidden'
      tokenInput.name = 'authenticity_token'
      tokenInput.value = csrfToken.getAttribute('content')
      form.appendChild(tokenInput)
    }

    document.body.appendChild(form)
    form.submit()
  }

  closeOnOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
