Rails.application.config.session_store :cookie_store, key: '_app_session', domain: Rails.env.production? ? 'plavco-d91619a02877.herokuapp.com' : 'localhost'
