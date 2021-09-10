module Repositories
  module Interactors
    class PullRequest
      include Interactor
      # context:
      #  project, branch_source

      attr_reader :service

      before do
        context.fail!(error: 'missing project') unless context.project
        context.fail!(error: 'project must be finished') unless context.project.finalized?
        context.fail!(error: 'missing source branch') unless context.branch_source
      end

      def call
        initialize_service
        create_pull_request
      end

      private

      def initialize_service
        @service = CreateService.for(repository)
      end

      def repository
        context.project.repository
      end

      def create_pull_request
        branch_destination = repository.branch_pull_request_destination
        response = service.create_pull_request(title, branch_destination, context.branch_source)
        return persisted_pull_request!(response[:data]) if (200..299).cover?(response[:status])

        context.fail!(error: response[:data][:error][:message])
      end

      def title
        file_name = context.project.file_path.split('/').last
        "Update locale #{file_name}"
      end

      def persisted_pull_request!(body)
        attributes = {
          external_id: body[:id],
          project: context.project,
          locale_file: context.project.locale_file,
          status: :open
        }
        ::PullRequest.create!(attributes)
      end
    end
  end
end
