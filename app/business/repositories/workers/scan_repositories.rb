module Repositories
  module Workers
    class ScanRepositories
      include Sidekiq::Worker
      sidekiq_options queue: 'repositories', retry: true

      def perform
        Repository.find_each do |repo|
          Repositories::Workers::ScanRepository.perform_async(repo.id)
        end
      end
    end
  end
end
