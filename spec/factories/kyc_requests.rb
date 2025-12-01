FactoryBot.define do
  factory :kyc_request do
    client { nil }
    status { "MyString" }
    document_type { "MyString" }
    document_number { "MyString" }
    rejection_reason { "MyString" }
  end
end
