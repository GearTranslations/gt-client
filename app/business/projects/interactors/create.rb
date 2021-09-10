module Projects
  module Interactors
    class Create
      include Interactor
      # context:
      #  project, file

      attr_reader :service

      before do
        context.fail!(error: 'missing project') unless context.project
        context.fail!(error: 'project is not open') unless context.project.open?
        context.fail!(error: 'missing file') unless context.file
      end

      def call
        initialize_service
        project.processing!
        create_project!
      rescue HTTP::Error => e
        project.fail!
        context.fail!(error: e.message)
      end

      private

      def project
        context.project
      end

      def create_project!
        response = service.create_project(context.file, project.algined_from,
                                          project.language_to)
        status = response[:status]
        return handle_error(response) unless (200..299).cover?(status)

        project.update!(external_id: response.dig(:data, :projects).first[:id])
      end

      def handle_error(response)
        project.fail!
        context.fail!(error: response[:data][:error])
      end

      def initialize_service
        @service = ::GearTranslation::Client.new(project.access_token)
      end
    end
  end
end
