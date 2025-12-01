module Api
  module V1
    class FailureApp < Devise::FailureApp
      def respond
        if api_request?
          json_error_response
        else
          super
        end
      end

      private

      def api_request?
        request.path.start_with?('/api/') || request.format == :json
      end

      def json_error_response
        self.status = 401
        self.content_type = 'application/json'
        self.response_body = {
          error: 'Unauthorized',
          message: i18n_message || 'You need to sign in or sign up before continuing.'
        }.to_json
      end
    end
  end
end


