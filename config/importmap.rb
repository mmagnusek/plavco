# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "controllers/booking_modal_controller", to: "controllers/booking_modal_controller.js"
pin "controllers/toast_controller", to: "controllers/toast_controller.js"
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.18
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.18
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.0.300
