module Repositories
  module Workers
    class ScanRepository
      class ScanRepositoryError < StandardError; end
      include Sidekiq::Worker
      sidekiq_options queue: 'repositories', retry: true

      def perform(repository_id)
        repository = Repository.find(repository_id)
        result = repository.scan

        raise ScanRepositoryError, result.error if result.failure?
      end
    end
  end
end
