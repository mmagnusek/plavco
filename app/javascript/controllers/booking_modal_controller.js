import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

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

  async confirm() {
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

    try {
      // Use @rails/request.js to make the POST request
      const response = await post(`/slots/${slotId}/bookings`, {
        body: JSON.stringify({
          user_id: userId,
          week_start: weekParam
        }),
        headers: {
          'Accept': 'text/vnd.turbo-stream.html'
        }
      })

      if (response.ok) {
        // Close the modal on successful booking
        this.close()
      } else {
        // Handle error response
        const errorData = await response.text
        console.error('Booking failed:', errorData)
        alert('Failed to book the slot. Please try again.')
      }
    } catch (error) {
      console.error('Error booking slot:', error)
      alert('An error occurred while booking the slot. Please try again.')
    }
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
