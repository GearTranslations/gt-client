module Projects
  module Interactors
    class GetFileAndCreateProject
      include Interactor::Organizer

      # This interactor is in charge of the full process of creation of a new
      # project in gear
      # 1 - get the locale from repository
      # 2 - create the project
      organize Repositories::Interactors::GetFile, Create
    end
  end
end
