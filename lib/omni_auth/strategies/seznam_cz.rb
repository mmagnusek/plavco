module OmniAuth
  module Strategies
    # Main class for Seznam.cz strategy.
    class SeznamCz < OmniAuth::Strategies::OAuth2
      ALLOWED_ISSUERS = ['login.szn.cz'].freeze
      BASE_SCOPES = %w[identity contact-phone avatar].freeze
      DEFAULT_SCOPE = 'identity'
      USER_INFO_URL = 'https://login.szn.cz/api/v1/user'

      option :name, 'seznam_cz'
      option :skip_image_info, true
      option :authorize_options, %i[scope state redirect_uri]
      option :authorized_client_ids, []

      option :client_options,
             site: 'https://login.szn.cz',
             authorize_url: '/api/v1/oauth/auth',
             token_url: '/api/v1/oauth/token',
             auth_scheme: :request_body

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end

          params[:scope] = get_scope(params)
          session['omniauth.state'] = params[:state] if params[:state]
        end
      end

      uid { raw_info['oauth_user_id'] }

      info do
        {
          name: "#{raw_info['firstname']} #{raw_info['lastname']}",
          email: "#{raw_info['username']}@#{raw_info['domain']}",
          firstname: raw_info['firstname'],
          lastname: raw_info['lastname'],
          contact_phone: raw_info['contact-phone'],
          avatar_url: raw_info['avatar-url']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def callback_url
        full_host + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get(USER_INFO_URL).parsed
      end

      private

      def get_scope(params)
        raw_scope = params[:scope] || DEFAULT_SCOPE
        scope_list = raw_scope.split(' ').map { |item| item.split(',') }.flatten
        scope_list.join(',')
      end
    end
  end
end
