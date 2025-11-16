class Product < ApplicationRecord
  has_many :subscriptions
  has_many :license_assignments
  has_many :accounts, through: :subscriptions

  validates :name, presence: true
  validates :description, presence: true
end
