// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import { Application } from "@hotwired/stimulus"
import BookingModalController from "controllers/booking_modal_controller"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// Register controllers
application.register("booking-modal", BookingModalController)

export { application }
