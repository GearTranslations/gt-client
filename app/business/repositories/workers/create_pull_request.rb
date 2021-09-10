module Repositories
  module Workers
    class CreatePullRequest
      class CreatePullRequestError < StandardError; end
      include Sidekiq::Worker
      sidekiq_options queue: 'pull_requests', retry: true

      def perform(project_id)
        project = Project.find(project_id)
        result = Interactors::CreatePullRequest.call(project: project)

        raise CreatePullRequestError, result.error if result.failure?
      end
    end
  end
end
