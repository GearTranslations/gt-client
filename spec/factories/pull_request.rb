FactoryBot.define do
  factory :pull_request do
    status { 0 }
    external_id { Faker::IDNumber.brazilian_id }

    locale_file { create :locale_file }
    project { create :project, locale_file: locale_file, status: :finalized }
  end
end
