module Projects
  module Workers
    class ProcessProjects
      include Sidekiq::Worker
      sidekiq_options queue: 'projects', retry: true

      def perform
        Project.where(status: :open).find_each do |project|
          ProcessProject.perform_async(project.id)
        end
      end
    end
  end
end
