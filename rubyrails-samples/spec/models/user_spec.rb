require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  # Email validations
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should allow_value("user@example.com").for(:email) }
  it { should_not allow_value("invalid_email").for(:email) }

  # Password validations
  it { should validate_presence_of(:password) }
  it { should validate_confirmation_of(:password) }
  it { should validate_length_of(:password).is_at_least(12) }

  it "is valid with a valid user" do
    expect(build(:user)).to be_valid
  end

  describe "Devise modules" do
    # Database Authenticatable
    it "authenticates with valid password" do
      user = create(:user, password: "Password0123456789$")
      expect(user.valid_password?("Password0123456789$")).to be true
    end

    # Registerable (covered by factory and validations)

    # Recoverable
    it "generates a reset password token" do
      user = create(:user)
      enc = Devise.token_generator.generate(User, :reset_password_token)
      user.reset_password_token = enc
      user.reset_password_sent_at = Time.current
      user.save!
      expect(user.reset_password_token).not_to be_nil
      expect(user.reset_password_sent_at).not_to be_nil
    end

    # Rememberable
    it "remembers a user" do
      user = create(:user)
      user.remember_me!
      expect(user.remember_created_at).not_to be_nil
    end

    # Trackable
    it "tracks sign in count" do
      user = create(:user)
      fake_request = double(remote_ip: "127.0.0.1")
      expect { user.update_tracked_fields!(fake_request) }.to change { user.sign_in_count }.by(1)
    end

    # Confirmable
    it "is confirmable" do
      user = build(:user, confirmed_at: nil)
      expect(user.confirmed?).to be false
      user.confirm
      expect(user.confirmed?).to be true
    end

    # Lockable
    it "is lockable" do
      user = create(:user)
      user.locked_at = Time.current
      user.save!
      expect(user.access_locked?).to be true
    end

    # Timeoutable
    # it "times out after inactivity" do
    #   user = create(:user)
    #   last_activity = 3.hours.ago
    #   expect(user.timedout?(last_activity)).to be true
    # end
  end
end
