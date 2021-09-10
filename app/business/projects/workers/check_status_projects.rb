module Projects
  module Workers
    class CheckStatusProjects
      include Sidekiq::Worker
      sidekiq_options queue: 'projects', retry: true

      def perform
        Project.where(status: :processing).find_each do |project|
          CheckStatusProject.perform_async(project.id)
        end
      end
    end
  end
end
