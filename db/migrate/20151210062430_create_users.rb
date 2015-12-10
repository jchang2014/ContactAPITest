class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.integer :concierge_id
    	t.string :name
    	t.string :email
    	t.string :title
    	t.string :company
    	t.string :photo_url
    	t.string :source

      t.timestamps null: false
    end
  end
end
