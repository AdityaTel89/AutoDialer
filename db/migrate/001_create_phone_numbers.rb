class CreatePhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    create_table :phone_numbers do |t|
      t.string :number, null: false
      t.string :status, default: 'pending'
      t.integer :batch_id
      t.datetime :uploaded_at
      t.timestamps
    end
    
    add_index :phone_numbers, :number
    add_index :phone_numbers, :batch_id
    add_index :phone_numbers, :status
  end
end
