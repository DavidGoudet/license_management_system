class User < ApplicationRecord
  belongs_to :account
  has_many :license_assignments, dependent: :destroy
  has_many :products, through: :license_assignments

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :without_product_license, ->(product_id) {
    where.not(id: LicenseAssignment.where(product_id: product_id).select(:user_id))
  }

  def has_license_for?(product)
    license_assignments.exists?(product_id: product.id)
  end
end
