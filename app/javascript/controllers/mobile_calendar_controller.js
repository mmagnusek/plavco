import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-calendar"
export default class extends Controller {
  static values = {
    currentDayIndex: Number
  }

  connect() {
    this.days = Array.from(this.element.querySelectorAll('.calendar-day')).map(day => ({
      element: day,
      dayNum: parseInt(day.dataset.day),
      index: parseInt(day.dataset.dayIndex)
    }))

    this.currentDayIndex = this.currentDayIndexValue
    this.showDay(this.currentDayIndex)

    // Handle window resize
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
  }

  handleResize() {
    if (this.isMobile()) {
      this.showDay(this.currentDayIndex)
    } else {
      // On desktop, show all days - remove inline styles
      this.days.forEach(day => {
        day.element.style.display = null
      })
    }
  }

  prevDay() {
    this.currentDayIndex--
    this.showDay(this.currentDayIndex)
  }

  nextDay() {
    this.currentDayIndex++
    this.showDay(this.currentDayIndex)
  }

  showDay(index) {
    const day = this.days[index]
    if (!day) return
    if (!this.isMobile()) return

    this.days.forEach(d => {
      if (d.element === day.element) {
        // Show selected day
        d.element.style.display = 'block'
      } else {
        // Hide all other days
        d.element.style.display = 'none'
      }
    })
  }

  isMobile() {
    return window.innerWidth < 768 // md breakpoint in Tailwind
  }
}
