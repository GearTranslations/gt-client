module Repositories
  module Workers
    class CheckPullRequests
      include Sidekiq::Worker
      sidekiq_options queue: 'pull_requests', retry: true

      def perform
        PullRequest.where(status: :open).find_each do |pull_request|
          Repositories::Workers::CheckPullRequest.perform_async(pull_request.id)
        end
      end
    end
  end
end
