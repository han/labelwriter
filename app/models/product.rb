require 'csv'
require 'barby'
require 'barby/barcode/ean_13'
require 'barby/outputter/prawn_outputter'

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
      end
    end
  end

  # 1.Identify key fields, update migration
  # 2.Read both articles and fetim_article_numbers files. Key of fetim
  # file, get additional data from articles file
  # 3.Identify existing field, and update if needed. Otherwise save a
  # new record
  # Error handling: text existence of needed fields. Dismiss if not
  # found. Do this for both files.

  def barcode
    Barby::EAN13.new('8711253806104')
  end
end
