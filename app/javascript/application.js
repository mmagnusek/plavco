// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import BookingModalController from "controllers/booking_modal_controller"
import ToastController from "controllers/toast_controller"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// Register controllers
application.register("booking-modal", BookingModalController)
application.register("toast", ToastController)

export { application }
