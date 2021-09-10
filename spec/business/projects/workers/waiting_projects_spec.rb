describe Projects::Workers::WaitingProjects do
  describe '#perform' do
    subject(:worker_result) { described_class.new.perform }

    let(:repository) { project.repository }
    let(:locale_file) { project.locale_file }
    let!(:project) { create :project, status: :waiting }

    it 'change status to open' do
      worker_result
      expect(project.reload.status).to eq('open')
    end

    context 'when there is a project open' do
      before do
        create :project, status: :open, locale_file: locale_file
      end

      it 'not change status' do
        expect { worker_result }.not_to change(project, :status)
      end
    end

    context 'when there is a project processing' do
      before do
        create :project, status: :processing, locale_file: locale_file
      end

      it 'not change status' do
        expect { worker_result }.not_to change(project, :status)
      end
    end

    context 'when there is more than one waiting' do
      let!(:recent_project) { create :project, status: :waiting, locale_file: locale_file }

      it 'change status to open' do
        worker_result
        expect(project.reload.status).to eq('open')
      end

      it 'not change status' do
        expect { worker_result }.not_to change(recent_project, :status)
      end
    end
  end
end
