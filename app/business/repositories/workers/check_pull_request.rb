module Repositories
  module Workers
    class CheckPullRequest
      class CheckPullRequestError < StandardError; end
      include Sidekiq::Worker
      sidekiq_options queue: 'pull_requests', retry: true

      def perform(pull_request_id)
        pull_request = PullRequest.find(pull_request_id)
        result = Repositories::Interactors::CheckPullRequest.call(pull_request: pull_request)

        raise CheckPullRequestError, result.error if result.failure?
      end
    end
  end
end
