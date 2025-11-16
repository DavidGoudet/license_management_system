class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :number_of_licenses, null: false
      t.datetime :issued_at, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :subscriptions, [ :account_id, :product_id ]
  end
end
