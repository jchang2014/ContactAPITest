class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
    	t.text :response_hash 
    	t.string :source
    	t.references :user, index: true

      t.timestamps null: false
    end
  end
end
