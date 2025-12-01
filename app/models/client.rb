class Client < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  has_one :client_wallet, dependent: :destroy
  has_many :client_operations
  has_many :client_topups
  has_many :service_imoneys
  has_many :client_topup_drafts
  has_many :service_imoney_drafts
  has_many :kyc_requests
  has_many :lotto_bets

  after_create :create_primary_wallet

  def create_primary_wallet
    create_client_wallet!(
      wallet_type: :primary_wallet,
      real_balance: 0.0,
      theoretical_balance: 0.0,
      locked: false
    )
  rescue => e
    Rails.logger.error "Failed to create primary wallet: #{e.message}"
    raise
  end

  before_create :set_jti

  def set_jti
    self.jti = SecureRandom.uuid
  end

  # JWT revocation simple
  # Un token est révoqué si le jti de l'utilisateur est nil (révoqué explicitement)
  # ou si le jti ne correspond pas (token invalide)
  def self.jwt_revoked?(payload, user)
    return true if user.nil?
    return true if user.jti.nil? # Token révoqué explicitement
    user.jti != payload['jti'] # Token invalide si jti ne correspond pas
  end

  def self.revoke_jwt(payload, user)
    user.update(jti: nil) if user
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  # Override Devise's find_for_database_authentication to use phone
  def self.find_for_database_authentication(conditions)
    if conditions[:phone].present?
      find_by(phone: conditions[:phone])
    else
      super
    end
  end
end
