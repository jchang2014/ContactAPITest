class CreateProspectorProfile < ActiveRecord::Migration
  def change
    create_table :prospector_profiles do |t|
    	t.string :first_name
    	t.string :last_name
    	t.string :full_name
    	t.string :title

    	t.timestamps
    end
  end
end
