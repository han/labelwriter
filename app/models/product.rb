require 'csv'
require 'barby'
require 'barby/barcode/ean_13'
require 'barby/outputter/prawn_outputter'
require 'csv_tools'

class Product < ActiveRecord::Base

  has_many :deliveries

  validates :item_code, :fetim_code, :presence => true
  validates :num_in_buy, :per_pack_un, :max_pallet, :numericality => {:only_integer => true}, :allow_blank => true

  BRANDS = Hash.new('').merge({
    159 => 'AirPro',
    103 => 'IVC Air',
    144 => 'Sencys'
  })

  COLUMNS = {
    'Artikelnummer' => 'item_code',
    'Artikelgroep' => 'item_grp_code',
    'Barcode' => 'code_bars',
    'Aantal artikelen per inkoopeenheid' => 'num_in_buy',
    'Hoeveelheid per verpakkingseenheid' => 'per_pack_un',
    'overall diameter [mm]' => 'size',
    'Omschrijving label' => 'omlabel',
    'Maximaal aantal dozen p pallet' => 'max_pallet',
    'Catalogusnummer ZP' => 'fetim_code'
  }

  def self.import_csv(product_file, fetim_file)
    products_text, products_sep = CsvTools.prep_csv(product_file, '#')
    fetim_text, fetim_sep = CsvTools.prep_csv(fetim_file, '#')

    fetim_codes = {}
    CSV.parse(fetim_text, :col_sep => fetim_sep, :headers => true, :skip_blanks => true).each do |row|
      next if row.header_row?
      fetim_codes[ row['Artikelnummer'] ] = row['Catalogusnummer ZP']
    end

    CSV.parse(products_text, :col_sep => products_sep, :headers => true, :skip_blanks => true, :converters => :all).each do |row|
      next if row.header_row?
        params = {}
        row.each {|k,v| params[COLUMNS[k]] = v if COLUMNS[k]}
        params['item_grp_code'] = BRANDS[params['item_grp_code']]
        params['fetim_code'] = fetim_codes[params['item_code']] if fetim_codes[params['item_code']]
        details = (row['Artikelomschrijving'] || '').split(' - ')
        if details.count >= 4
          params[:omlabel] = details[1].gsub(/(air\s?pro)|(ivc\s?air)|(sencys)/i,'')
          params[:size] ||= details[3]
        end
        existing = Product.find_by_item_code params['item_code']
        if existing
          existing.update_attributes params
        else
          create params
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
    Barby::EAN13.new(self.code_bars) if self.code_bars.present?
  end

  def delete!
    self.status = 'deleted'
    save
  end

end
