module Projects
  module Interactors
    class GetTranslatedFile
      include Interactor

      # context:
      #   project
      # added to context
      #   file

      attr_reader :service

      before do
        context.fail!(error: 'missing project') unless context.project
        context.fail!(error: 'project is not finalized') unless context.project.finalized?
      end

      def call
        initialize_service
        context.file = translated_file
      end

      private

      def translated_file
        response = service.translated_file(project.external_id)
        status = response[:status]
        context.fail!(error: response[:data][:error]) unless (200..299).cover?(status)
        temp_file = File.open(temp_file_name, 'w+')
        temp_file.write(response[:data].force_encoding('UTF-8'))
        temp_file.close
        temp_file
      end

      def temp_file_name
        "tmp/#{File.basename(project.file_path)}"
      end

      def project
        context.project
      end

      def repository
        context.project.repository
      end

      def initialize_service
        @service = ::GearTranslation::Client.new(project.access_token)
      end
    end
  end
end
