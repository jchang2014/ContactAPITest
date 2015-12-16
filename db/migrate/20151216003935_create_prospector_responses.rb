class CreateProspectorResponses < ActiveRecord::Migration
  def change
    create_table :prospector_responses do |t|
    	t.text :response_hash
    	
    	t.timestamps
    end
  end
end
