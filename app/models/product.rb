require 'csv'

class Product < ActiveRecord::Base
  has_many :deliveries

  def self.import_csv(file)
    return false unless file.present?
    csv = CSV.parse(file.read, :col_sep => ';', :headers => true, :skip_blanks => true)
    Product.transaction do
      csv.each do |row|
        next if row.header_row?
        params = {}
        row.each {|k,v| params[k] = v}
        existing = Product.find_by_item_code params['item_code']
        if existing
          existing.update_attributes params
        else
          create params
        end
        # Rails.logger.info row.inspect
      end
    end
  end
end
