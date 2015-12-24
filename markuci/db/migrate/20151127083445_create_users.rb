class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :emp_no
      t.string :dept
      t.string :address

      t.timestamps null: false
    end
  end
end
