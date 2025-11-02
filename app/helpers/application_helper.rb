module ApplicationHelper
  def tv(key, **options)
    t(key, **options.merge(scope: "views"))
  end
end
