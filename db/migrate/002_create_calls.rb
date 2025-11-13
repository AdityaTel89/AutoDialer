class CreateCalls < ActiveRecord::Migration[7.1]
  def change
    create_table :calls do |t|
      t.references :phone_number, null: false, foreign_key: true
      t.string :twilio_sid
      t.string :status, default: 'queued'
      t.string :direction, default: 'outbound'
      t.integer :duration
      t.datetime :started_at
      t.datetime :ended_at
      t.text :ai_prompt
      t.text :transcript
      t.json :metadata
      t.timestamps
    end
    
    add_index :calls, :twilio_sid
    add_index :calls, :status
    add_index :calls, :started_at
  end
end
