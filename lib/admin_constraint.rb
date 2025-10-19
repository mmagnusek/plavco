class AdminConstraint
  def matches?(request)
    return false unless request.cookies.key?('session_id')

    # Use the same logic as the Authentication concern
    cookie_value = request.cookies['session_id']
    return false unless cookie_value

    # Create a cookie jar to decode the signed cookie the same way Rails does
    cookie_jar = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
    session_id = cookie_jar.signed[:session_id]

    return false unless session_id

    session = Session.find_by(id: session_id)
    return false unless session

    session.user&.admin?
  rescue => e
    # If anything goes wrong (invalid signature, missing session, etc.), deny access
    false
  end
end
