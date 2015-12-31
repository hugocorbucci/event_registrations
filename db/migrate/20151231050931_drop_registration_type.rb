class DropRegistrationType < ActiveRecord::Migration
  def change
    drop_table :registration_types do |t|
      t.references :event
      t.string :title
      t.timestamps
    end

    remove_column :attendances, :registration_type_id, type: :integer
  end
end