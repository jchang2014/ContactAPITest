class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
    	t.string :name
    	t.string :title
    	t.string :company
    	t.string :photo_url
    	t.string :source
    	t.string :tags
    	t.references :user_id

      t.timestamps null: false
    end
  end
end
