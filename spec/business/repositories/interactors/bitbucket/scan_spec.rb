describe Repositories::Interactors::Bitbucket::Scan do
  describe '.call' do
    subject(:interactor_result) do
      described_class.call(repository: repository)
    end

    let(:repository) { create :repository_bitbucket }
    let(:client) do
      Bitbucket::Client.new(repository)
    end

    let(:success_response) do
      { status: 200,
        data: file_fixture('bitbucket/geartranslations.yml') }.deep_symbolize_keys
    end

    let(:commit_last_update_date) { DateTime.new(2021, 8, 8, 7, 37, 0) }
    let(:last_commit_message) { 'added key to locale' }

    let(:last_file_change_response) do
      {
        status: 200,
        data: {
          values: [
            { commit: { date: commit_last_update_date,
                        message: last_commit_message },
              path: 'config/locales/en.json' }
          ]
        }
      }.deep_symbolize_keys
    end

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(client)
      allow(client).to receive(:file).and_return(success_response)
      allow(client).to receive(:last_file_change).and_return(last_file_change_response)
    end

    it 'call get file' do
      interactor_result
      expect(client).to have_received(:file).with(repository.branch, 'geartranslations.yml')
    end

    it 'creates locale files' do
      expect { interactor_result }.to change(LocaleFile, :count).from(0).to(2)
    end

    it 'creates projects' do
      expect { interactor_result }.to change(Project, :count).from(0).to(2)
    end

    it 'set access_token' do
      interactor_result
      expect(Project.first).to have_attributes(access_token: 'accesstoken')
      expect(Project.second).to have_attributes(access_token: 'accesstoken')
    end

    context 'when the locale does not change' do
      let(:next_commit_last_update_date) { commit_last_update_date + 1.hour }
      let(:locale_fr) do
        create :locale_file, name: 'locales/fr.json', repository_id: repository.id,
                             last_update_date: next_commit_last_update_date
      end
      let(:locale_en) do
        create :locale_file, name: 'locales/en.json', repository_id: repository.id,
                             last_update_date: next_commit_last_update_date
      end

      before do
        locale_fr
        locale_en
      end

      it 'do not create projects' do
        expect { interactor_result }.not_to change(Project, :count)
      end

      it 'do not update the last update date' do
        expect(locale_fr.reload.last_update_date).to eq(next_commit_last_update_date)
        expect(locale_en.reload.last_update_date).to eq(next_commit_last_update_date)
      end
    end

    context 'when the locale changes' do
      let(:previous_commit_last_update_date) { commit_last_update_date - 1.hour }
      let(:locale_fr) do
        create :locale_file, name: 'locales/fr.json', repository_id: repository.id,
                             last_update_date: previous_commit_last_update_date,
                             last_commit_message: 'Added key to fr locale'
      end
      let(:locale_en) do
        create :locale_file, name: 'locales/en.json', repository_id: repository.id,
                             last_update_date: previous_commit_last_update_date,
                             last_commit_message: 'Added key to en locale'
      end

      before do
        locale_fr
        locale_en
      end

      it 'creates projects' do
        expect { interactor_result }.to change(Project, :count).from(0).to(2)
      end

      it 'update the last update date' do
        interactor_result
        expect(locale_fr.reload.last_update_date).to eq(commit_last_update_date)
        expect(locale_en.reload.last_update_date).to eq(commit_last_update_date)
      end

      it 'update the commit message' do
        interactor_result
        expect(locale_fr.reload.last_commit_message).to eq(last_commit_message)
        expect(locale_en.reload.last_commit_message).to eq(last_commit_message)
      end

      # NOTE(waiting): This functionality is without effect at the moment
      xcontext 'when there is a project in progress' do
        let(:in_process_project) do
          create :project, locale_file: locale_en, status: :processing,
                           file_path: 'locales/en.json'
        end

        before do
          in_process_project
        end

        it 'create project with status waiting' do
          interactor_result
          expect(
            Project.where(locale_file_id: in_process_project.locale_file.id,
                          file_path: 'locales/en.json', status: :waiting)
          ).to exist
        end
      end

      # NOTE(waiting): This functionality is without effect at the moment
      xcontext 'when there is a project open' do
        let(:in_open_project) do
          create :project, locale_file: locale_en, status: :open,
                           file_path: 'locales/en.json'
        end

        before do
          in_open_project
        end

        it 'create project with status waiting' do
          interactor_result
          expect(
            Project.where(locale_file_id: locale_en.id, file_path: 'locales/en.json',
                          status: :waiting)
          ).to exist
        end
      end

      context 'when the locale change by the pull request' do
        let(:last_commit_message) { 'Updated locale from gt-api-client' }

        it 'do not create the project' do
          expect { interactor_result }.not_to change(Project, :count)
        end

        it 'do not update the last update date' do
          expect { interactor_result }.not_to change(locale_fr, :last_update_date)
          expect { interactor_result }.not_to change(locale_en, :last_update_date)
        end

        it 'do not update the commit message' do
          expect { interactor_result }.not_to change(locale_fr, :last_commit_message)
          expect { interactor_result }.not_to change(locale_en, :last_commit_message)
        end
      end

      context 'when there is a pull request open' do
        before do
          create :pull_request, locale_file: locale_en, status: :open
          create :pull_request, locale_file: locale_fr, status: :open
        end

        it 'do not create the project' do
          expect { interactor_result }.not_to change(Project, :count)
        end
      end

      context 'when there is a pull request merged' do
        before do
          create :pull_request, locale_file: locale_en, status: :merged
          create :pull_request, locale_file: locale_fr, status: :merged
        end

        it 'creates projects' do
          expect { interactor_result }.to change(Project, :count).by(2)
        end
      end
    end
  end
end
