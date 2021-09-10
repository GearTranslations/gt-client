describe PullRequest do
  subject(:pull_request) do
    build :pull_request
  end

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:external_id) }
  it { is_expected.to validate_presence_of(:locale_file) }
  it { is_expected.to validate_presence_of(:project) }

  it do
    expect(pull_request).to(
      define_enum_for(:status).with_values(
        open: 0, merged: 10, declined: 20
      )
    )
  end
end
