FactoryBot.define do
  factory :user do
    email { "user@example.com" }
    password { "Password0123456789$" }
    password_confirmation { "Password0123456789$" }
    confirmed_at { Time.current }
  end

  factory :admin_user, class: "User" do
    email { "admin@example.com" }
    password { "Password0123456789$" }
    password_confirmation { "Password0123456789$" }
    confirmed_at { Time.current }
    admin { true }
  end

  factory :new_user, class: "User" do
    email { "new_user@example.com" }
    password { "NewPassword0123456789$" }
    password_confirmation { "NewPassword0123456789$" }
  end
end
