class LicenseAssignment < ApplicationRecord
  belongs_to :account
  belongs_to :user
  belongs_to :product

  validates :account_id, presence: true
  validates :user_id, presence: true
  validates :product_id, presence: true

  validates :user_id, uniqueness: {
    scope: [ :product_id, :account_id ],
    message: "already has a license for this product"
  }

  validate :user_belongs_to_account
  validate :active_subscription_exists, on: :create
  validate :licenses_available, on: :create

  private

    def user_belongs_to_account
      if user && account && user.account_id != account_id
        errors.add(:user, "must belong to the specified account")
      end
    end

  def active_subscription_exists
    return if account_id.blank? || product_id.blank?

    subscription = Subscription.active
                                .for_account_and_product(account_id, product_id)
                                .first

    if subscription.nil?
      errors.add(:base, "No active subscription found for this product")
    end
  end

  def licenses_available
    return if account_id.blank? || product_id.blank?

    total = Subscription.total_licenses_for(account_id, product_id)
    used = LicenseAssignment.where(
      account_id: account_id,
      product_id: product_id
    ).count

    if used >= total
      errors.add(:base, "No available licenses for this product")
    end
  end
end
