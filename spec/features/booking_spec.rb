require 'rails_helper'

RSpec.describe 'Booking a slot' do
  let(:next_week_start) { Date.current.beginning_of_week + 1.week }

  it 'allows a signed-in user to navigate to next week and book an available slot', js: true do
    # Sign in the user using the seeded password
    sign_in_as(user)

    visit '/'

    # Verify we're on the calendar page (after successful sign-in redirect)
    expect(page).to have_content('Swimming Training Calendar')
    expect(page).to have_content('Logged in as:')

    # Navigate to next week by clicking the next week arrow
    # The link has a title attribute with "Next Week" or similar
    click_link 'Next Week'

    wait_for_turbo

    # Wait for the page to load and verify we're viewing next week
    expect(page).to have_content(next_week_start.strftime('%B'))

    # Count bookings before
    booking_count_before = Booking.for_week(next_week_start).count

    # Accept the confirmation dialog if present
    accept_confirm do
      find(:button, text: 'Book Available Spot', match: :first, wait: 5).click
    end

    # Verify we see a success message (flashes.booking.created)
    expect(page).to have_content("Info! Calendar updated for week of #{next_week_start.strftime('%B %d, %Y')}")

    # Verify the booking was created
    booking_count_after = Booking.for_week(next_week_start).count
    expect(booking_count_after).to eq(booking_count_before + 1)
  end
end
