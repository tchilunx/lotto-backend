FactoryBot.define do
  factory :service_imoney do
    client { nil }
    amount { "9.99" }
    phone_number { "MyString" }
    status { "MyString" }
    reference { "MyString" }
    external_reference { "MyString" }
  end
end
