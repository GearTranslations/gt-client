module Repositories
  module Interactors
    class CreatePullRequest
      include Interactor::Organizer

      # This interactor is in charge of the full process of creation of a new
      # pull request
      # 1 - get the translated file from gt api
      # 2 - upload file in repository in new branch
      # 3 - create pull request

      # context:
      #   project
      # added to context
      #   file, branch_source

      # GetFile from gearstranslate api
      organize Projects::Interactors::GetTranslatedFile, UploadFile, PullRequest
    end
  end
end
