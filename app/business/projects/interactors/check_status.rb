module Projects
  module Interactors
    class CheckStatus
      include Interactor
      # context:
      #  project

      attr_reader :service

      before do
        context.fail!(error: 'missing project') unless context.project
        context.fail!(error: 'project is not processing') unless context.project.processing?
      end

      def call
        initialize_service
        check_project_status!
      end

      private

      def project
        context.project
      end

      def check_project_status!
        response = service.project_status(project.external_id)
        status = response[:status]
        return handle_error(response) unless (200..299).cover?(status)
        return unless response.dig(:data, :family_project_state) == 'finished'

        project.finalize!
        Repositories::Workers::CreatePullRequest.perform_async(project.id)
      end

      def handle_error(response)
        context.fail!(error: response[:data][:error])
      end

      def initialize_service
        @service = ::GearTranslation::Client.new(project.access_token)
      end
    end
  end
end
