class CreateLicenseAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :license_assignments do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    # Prevention of duplicate assignments - one license per user per product
    add_index :license_assignments,
              [ :user_id, :product_id, :account_id ],
              unique: true,
              name: 'index_license_assignments_uniqueness'

    # Index for efficiently counting used licenses
    add_index :license_assignments, [ :account_id, :product_id ]
  end
end
