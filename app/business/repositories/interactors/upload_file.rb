module Repositories
  module Interactors
    class UploadFile
      include Interactor

      # context:
      #   project, file
      # added to context
      #   branch_source

      attr_reader :service

      before do
        context.fail!(error: 'missing project') unless context.project
        context.fail!(error: 'project must be finished') unless context.project.finalized?
        context.fail!(error: 'missing file') unless context.file
      end

      def call
        initialize_service
        upload_file
      end

      private

      def upload_file
        response = service.upload_file(branch_name, context.file, upload_path, commit_message)
        return if (200..299).cover?(response[:status])

        context.fail!(error: response[:data][:error][:message])
      end

      def branch_name
        context.branch_source = "update-locale-#{branch_count!}"
        context.branch_source
      end

      def branch_count!
        Repository.transaction do
          repository.lock!
          count = repository.reload.branch_count + 1
          repository.branch_count = count
          repository.save!
          count
        end
      end

      def upload_path
        File.dirname(project.file_path)
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

      def commit_message
        file_name = project.file_path.split('/').last
        "Update locale #{file_name} from gt-api-client"
      end
    end
  end
end
