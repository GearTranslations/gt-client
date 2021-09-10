module Projects
  module Workers
    class CheckStatusProject
      class CheckStatusProjectError < StandardError; end
      include Sidekiq::Worker
      sidekiq_options queue: 'projects', retry: true

      def perform(project_id)
        project = Project.find(project_id)
        result = Projects::Interactors::CheckStatus.call(project: project)

        raise CheckStatusProjectError, result.error if result.failure?
      end
    end
  end
end
