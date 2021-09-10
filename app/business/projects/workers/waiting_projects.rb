module Projects
  module Workers
    class WaitingProjects
      include Sidekiq::Worker
      sidekiq_options queue: 'projects', retry: true

      def perform
        # NOTE: Default order id ASC
        # We need to process projects from older to newer
        Project.where(status: :waiting).find_each(&:try_to_open!)
      end
    end
  end
end
