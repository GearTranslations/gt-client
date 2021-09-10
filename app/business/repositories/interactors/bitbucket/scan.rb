module Repositories
  module Interactors
    module Bitbucket
      class Scan
        CONFIG_FILE_NAME = 'geartranslations.yml'.freeze
        DEFAULT_LAST_UPDATE_DATE = DateTime.new(2012, 8, 29, 22, 0, 0)
        GT_CLIENT_COMMIT_MESSAGE = 'gt-api-client'.freeze
        include Interactor

        # context:
        #  repository

        attr_reader :service

        before do
          context.fail!(error: 'missing repository') unless context.repository
        end

        def call
          initialize_service
          config_file = repository_config_file
          process_config_file!(config_file)
        end

        private

        def initialize_service
          @service = ::Bitbucket::Client.new(repository)
        end

        def repository
          context.repository
        end

        def repository_config_file
          response = service.file(repository.branch, CONFIG_FILE_NAME)
          unless (200..299).cover?(response[:status])
            context.fail!(error: response[:data][:error][:message])
          end
          YAML.safe_load(response[:data])
        end

        def last_commit(branch, file_name)
          response = service.last_file_change(branch, file_name)
          unless (200..299).cover?(response[:status])
            context.fail!(error: response[:data][:error][:message])
          end

          response[:data][:values].first[:commit]
        end

        def file_change?(locale_file)
          commit = last_commit(repository.branch, locale_file.name)
          if locale_file.last_update_date < commit[:date] && valid_message?(commit[:message])
            locale_file.update!(last_update_date: commit[:date],
                                last_commit_message: commit[:message])
            return true
          end

          false
        end

        def find_or_create_locale_file(file_name)
          locale = LocaleFile.find_or_create_by(name: file_name, repository_id: repository.id)
          locale.update!(last_update_date: DEFAULT_LAST_UPDATE_DATE) if locale.last_update_date.nil?
          locale.reload
        end

        def process_config_file!(config_file) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          tag = config_file['geartranslations']['tag']
          access_token = config_file['geartranslations']['access_token']
          config_file['geartranslations']['sources'].each do |source|
            file = source['file']
            locale_file = find_or_create_locale_file(file['name'])
            next if pull_request_open?(locale_file)
            next if project_open_or_processing?(locale_file)
            next unless file_change?(locale_file)

            attributes = {
              file_path: file['name'],
              language_to: file['locale'],
              algined_from: file['aligned_from'],
              file_format: file['format'],
              tag: tag,
              locale_file_id: locale_file.id,
              status: :open,
              access_token: access_token
            }

            Project.create!(attributes)
          end
        end

        # NOTE(waiting): This functionality is without effect at the moment
        # In the future to create waiting projects, you should check before going to open
        # if there is a pull request open
        def build_status(file_path, locale_file_id)
          is_project_in_process = Project.exists?(file_path: file_path,
                                                  locale_file_id: locale_file_id,
                                                  status: %i[open processing])
          return :waiting if is_project_in_process

          :open
        end

        def valid_message?(message)
          message.exclude?(GT_CLIENT_COMMIT_MESSAGE)
        end

        def pull_request_open?(locale_file)
          locale_file.pull_requests.any?(&:open?)
        end

        def project_open_or_processing?(locale_file)
          Project.exists?(locale_file_id: locale_file.id, status: %i[open processing])
        end
      end
    end
  end
end
