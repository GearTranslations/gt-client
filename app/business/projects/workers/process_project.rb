module Projects
  module Workers
    class ProcessProject
      class ProcessProjectError < StandardError; end
      include Sidekiq::Worker
      sidekiq_options queue: 'projects', retry: true

      def perform(project_id)
        project = Project.find(project_id)
        result = Projects::Interactors::GetFileAndCreateProject.call(project: project)

        raise ProcessProjectError, result.error if result.failure?
      end
    end
  end
end
