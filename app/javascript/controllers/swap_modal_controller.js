import { Controller } from "@hotwired/stimulus"
import { patch, post } from "@rails/request.js"

// Connects to data-controller="swap-modal"
export default class extends Controller {
  static targets = ["modal", "availableSlots", "bookingId", "slotId", "weekStart", "userId"]

  open(event) {
    const bookingId = event.target.dataset.bookingId
    const currentSlotId = event.target.dataset.slotId
    const weekStart = event.target.dataset.weekStart
    const userId = event.target.dataset.userId || ''

    this.bookingIdTarget.value = bookingId
    this.slotIdTarget.value = currentSlotId
    this.weekStartTarget.value = weekStart
    this.userIdTarget.value = userId

    this.loadAvailableSlots(weekStart, currentSlotId, userId)
    this.modalTarget.classList.remove('hidden')
  }

  openRegularSwap(event) {
    const currentSlotId = event.target.dataset.slotId
    const weekStart = event.target.dataset.weekStart
    const userId = event.target.dataset.userId || ''

    this.bookingIdTarget.value = ''
    this.slotIdTarget.value = currentSlotId
    this.weekStartTarget.value = weekStart
    this.userIdTarget.value = userId

    this.loadAvailableSlots(weekStart, currentSlotId, userId)
    this.modalTarget.classList.remove('hidden')
  }

  close() {
    this.modalTarget.classList.add('hidden')
    this.bookingIdTarget.value = ''
    this.slotIdTarget.value = ''
    this.weekStartTarget.value = ''
    this.userIdTarget.value = ''
    this.availableSlotsTarget.innerHTML = ''
  }

  closeOnOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  async loadAvailableSlots(weekStart, currentSlotId, userId) {
    try {
      let url = `/calendar?week=${weekStart}&format=json`
      if (userId && userId.trim() !== '') {
        url += `&user_id=${userId}`
      }
      const response = await fetch(url)
      const data = await response.json()

      this.availableSlotsTarget.innerHTML = ''

      data.slots.forEach(slot => {
        if (slot.id != currentSlotId && slot.available_spots > 0) {
          const slotElement = document.createElement('div')
          slotElement.className = 'p-3 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer'
          slotElement.innerHTML = `
            <div class="flex justify-between items-center">
              <div>
                <div class="font-medium">${slot.day_name} ${slot.time_range}</div>
                <div class="text-sm text-gray-600">${slot.available_spots}/${slot.max_participants} spots available</div>
              </div>
              <button
                class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm"
                data-action="click->swap-modal#confirmSwap"
                data-slot-id="${slot.id}"
              >
                Select
              </button>
            </div>
          `
          this.availableSlotsTarget.appendChild(slotElement)
        }
      })
    } catch (error) {
      console.error('Error loading available slots:', error)
      this.availableSlotsTarget.innerHTML = '<p class="text-red-500">Error loading available slots</p>'
    }
  }

  async confirmSwap(event) {
    const newSlotId = event.target.dataset.slotId
    const bookingId = this.bookingIdTarget.value
    const userId = this.userIdTarget.value

    if (!newSlotId) {
      alert('Missing slot information')
      return
    }

    try {
      let response

      if (bookingId) {
        // Temporal booking swap - update existing booking
        response = await patch(`/bookings/${bookingId}`, {
          body: JSON.stringify({
            slot_id: newSlotId
          }),
          headers: {
            'Accept': 'text/vnd.turbo-stream.html',
            'Content-Type': 'application/json'
          }
        })
      } else {
        // Regular attendee swap - create new booking with cancellation
        const requestBody = {
          week_start: this.weekStartTarget.value,
          cancelled_slot_id: this.slotIdTarget.value
        }

        // Only include user_id if it's provided (admin case)
        if (userId) {
          requestBody.user_id = userId
        }

        response = await post(`/slots/${newSlotId}/bookings`, {
          body: JSON.stringify(requestBody),
          headers: {
            'Accept': 'text/vnd.turbo-stream.html',
            'Content-Type': 'application/json'
          }
        })
      }

      if (response.ok) {
        this.close()
      } else {
        const errorData = await response.text
        console.error('Swap failed:', errorData)
        alert('Failed to swap the booking. Please try again.')
      }
    } catch (error) {
      console.error('Error swapping booking:', error)
      alert('An error occurred while swapping the booking. Please try again.')
    }
  }
}
