describe Project do
  subject(:project) do
    build :project
  end

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:file_path) }
  it { is_expected.to validate_presence_of(:algined_from) }
  it { is_expected.to validate_presence_of(:language_to) }
  it { is_expected.to validate_presence_of(:file_format) }

  it do
    expect(project).to(
      define_enum_for(:status).with_values(
        open: 0, processing: 10, finalized: 20, waiting: 30, failed: 40
      )
    )
  end
end
