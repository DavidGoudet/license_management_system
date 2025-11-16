class Subscription < ApplicationRecord
  belongs_to :account
  belongs_to :product

  validates :number_of_licenses, presence: true,
                                  numericality: { greater_than: 0, only_integer: true }
  validates :issued_at, presence: true
  validates :expires_at, presence: true
  validate :expires_at_after_issued_at

  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :for_account_and_product, ->(account_id, product_id) {
    where(account_id: account_id, product_id: product_id)
  }

  def active?
    expires_at > Time.current
  end

  def remaining_licenses
    return 0 unless active?

    total = Subscription.active
                        .for_account_and_product(account_id, product_id)
                        .sum(:number_of_licenses)

    used = LicenseAssignment.where(
      account_id: account_id,
      product_id: product_id
    ).count

    total - used
  end

  def used_licenses_count
    LicenseAssignment.where(
      account_id: account_id,
      product_id: product_id
    ).count
  end

  def self.total_licenses_for(account_id, product_id)
    active.for_account_and_product(account_id, product_id).sum(:number_of_licenses)
  end

  private

    def expires_at_after_issued_at
      return if expires_at.blank? || issued_at.blank?

      if expires_at <= issued_at
        errors.add(:expires_at, "must be after issued date")
      end
    end
end
