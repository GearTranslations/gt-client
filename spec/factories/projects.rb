FactoryBot.define do
  factory :project do
    status { 0 }
    external_id { nil }
    file_path { 'locale/file.json' }
    algined_from { 'es' }
    language_to { 'en-uk' }
    file_format { 'json' }
    tag { 'URGENT' }
    access_token { 'access_token' }

    locale_file { create :locale_file }
  end
end
