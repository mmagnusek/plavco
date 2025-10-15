import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking-modal"
export default class extends Controller {
  static targets = ["modal", "userSelect", "slotId"]

  open(event) {
    const participantIds = (event.target.dataset.participantIds || '').split(',').map(id => id.trim()).filter(id => id !== '')

    this.slotIdTarget.value = event.target.dataset.slotId
    this.modalTarget.classList.remove('hidden')
    this.userSelectTarget.value = ''
    this.disableParticipatingUsers(participantIds)
  }

  close() {
    this.modalTarget.classList.add('hidden')
    this.slotIdTarget.value = ''
    this.enableAllUsers()
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

    // Get current week from URL or use current date
    const urlParams = new URLSearchParams(window.location.search)
    const weekParam = urlParams.get('week') || new Date().toISOString().split('T')[0]

    // Create form and submit via Turbo
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = `/slots/${slotId}/book?user_id=${userId}&week_start=${weekParam}`
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

  disableParticipatingUsers(ids) {
    // First, enable all users
    this.enableAllUsers()

    ids.forEach(participantId => {
      const option = this.userSelectTarget.querySelector(`option[value="${participantId}"]`)
      if (option) {
        option.disabled = true
        option.style.color = '#9CA3AF' // gray-400
        option.style.backgroundColor = '#F3F4F6' // gray-100
      }
    })
  }

  enableAllUsers() {
    // Re-enable all user options
    const options = this.userSelectTarget.querySelectorAll('option')
    options.forEach(option => {
      option.disabled = false
      option.style.color = ''
      option.style.backgroundColor = ''
    })
  }
}
