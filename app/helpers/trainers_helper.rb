# frozen_string_literal: true

module TrainersHelper
  def slot_day_options_for_select
    Slot::DAYS_OF_WEEK.map { |d| [I18n.t('date.day_names')[d], d] }
  end

  def nav_link_class(path, prefix: false)
    base = "text-gray-600 hover:text-blue-700"
    active = if prefix
      base_path = path.to_s.chomp('/')
      request.path == base_path || request.path.start_with?("#{base_path}/")
    else
      current_page?(path)
    end
    base += " font-semibold text-blue-700" if active
    base
  end
end
