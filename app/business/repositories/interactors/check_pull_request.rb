module Repositories
  module Interactors
    class CheckPullRequest
      include Interactor

      # context:
      #   pull_request
      attr_reader :service

      before do
        context.fail!(error: 'missing pull request') unless context.pull_request
        context.fail!(error: 'pull request is not open') unless context.pull_request.open?
      end

      def call
        initialize_service
        check_pull_request_status!
      end

      private

      def check_pull_request_status!
        response = service.get_pull_request(pull_request.external_id)
        return update_pull_request!(response[:data]) if (200..299).cover?(response[:status])

        context.fail!(error: response[:data][:error][:message])
      end

      def update_pull_request!(body)
        case body[:state]
        when 'MERGED'
          pull_request.merge!
        when 'DECLINED'
          pull_request.decline!
        end
      end

      def initialize_service
        @service = CreateService.for(repository)
      end

      def repository
        context.pull_request.locale_file.repository
      end

      def pull_request
        context.pull_request
      end
    end
  end
end
