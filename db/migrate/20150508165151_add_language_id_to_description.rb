class AddLanguageIdToDescription < ActiveRecord::Migration
  def up
    add_column :descriptions, :language_id, :integer
    Description.reset_column_information
    
    TopicalMap::Category.all.select{ |c| c.descriptions.count==1 }.each do |c|
      f = Feature.get_by_fid(c.id)
      next if f.descriptions.count != 1
      f.descriptions.first.update_attribute(:language_id, Language.get_by_code(c.descriptions.first.language.code).id)
    end
    
    Description.where(language_id: nil).each do |d|
      old_desc = TopicalMap::Description.where(content: d.content).first
      next if old_desc.nil?
      lang_code = old_desc.language.code
      lang_code = 'bod' if lang_code.blank?
      d.update_attribute(:language_id, Language.get_by_code(lang_code).id)
    end
    eng = Language.get_by_code('eng').id
    Description.where(language_id: nil).update_all(language_id: eng)
    
    change_column :descriptions, :language_id, :integer, :null => false
  end
  
  def down
    remove_column :descriptions, :language_id
  end
end
