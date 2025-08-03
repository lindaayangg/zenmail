class User < ApplicationRecord
  # OAuth-only authentication - no passwords
  include Clearance::User

  has_one_attached :company_logo

  # Override Clearance's password validation for OAuth-only users
  def password_optional?
    true
  end

  # Override encrypted_password to avoid errors for OAuth-only users
  def encrypted_password
    nil
  end

  def encrypted_password=(value)
    # Do nothing - we don't use passwords
  end

  def self.from_omniauth(auth)
    return nil unless auth

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
    end
  end
end
