module Repositories
  module Interactors
    class GetFile
      include Interactor

      # context:
      #   project
      # added to context
      #   file
      attr_reader :service

      before do
        context.fail!(error: 'missing project') unless context.project
      end

      def call
        initialize_service
        context.file = file
      end

      private

      def file # rubocop:disable Metrics/AbcSize
        response = service.file(repository.branch, project.file_path)
        status = response[:status]
        context.fail!(error: response[:data][:error][:message]) unless (200..299).cover?(status)
        temp_file = File.open(temp_file_name, 'w+')
        temp_file.write(response[:data].force_encoding('UTF-8'))
        temp_file.close
        temp_file
      end

      def temp_file_name
        # "files/#{repository.repository_name}/#{project.file_path}"
        "tmp/#{repository.repository_name}-#{File.basename(project.file_path)}"
      end

      def initialize_service
        @service = CreateService.for(repository)
      end

      def repository
        context.project.repository
      end

      def project
        context.project
      end
    end
  end
end
