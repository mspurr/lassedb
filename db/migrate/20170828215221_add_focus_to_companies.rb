class AddFocusToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :focus, :text
  end
end
