require 'csv'
require 'barby'
require 'barby/barcode/ean_13'
require 'barby/outputter/prawn_outputter'
require 'csv_tools'

class Product < ActiveRecord::Base

  has_many :deliveries

  attr_accessible :item_code, :item_grp_code, :code_bars, :num_in_buy, :per_pack_un, :size,
    :omlabel, :max_pallet, :fetim_code, :width, :length, :height

  validates :item_code, :fetim_code, :presence => true
  validates :num_in_buy, :per_pack_un, :max_pallet, :numericality => {:only_integer => true}, :allow_blank => true

  before_save :determine_max_pallet

  BRANDS = Hash.new('').merge({
    159 => 'Air Pro',
    103 => 'IVC air',
    144 => 'Sencys'
  })

  COLUMNS = {
    'Artikelnummer' => 'item_code',
    'Artikelgroep' => 'item_grp_code',
    'Artikelnummer Fetim' => 'fetim_code',
    'Barcode' => 'code_bars',
    'Aantal artikelen per inkoopeenheid' => 'num_in_buy',
    'Hoeveelheid per verpakkingseenheid' => 'per_pack_un',
    'overall diameter [mm]' => 'size',
    'Omschrijving label' => 'omlabel',
    'Maximaal aantal dozen p pallet' => 'max_pallet',
    'Catalogusnummer ZP' => 'fetim_code',
    'L' => 'length',
    'B' => 'width',
    'H' => 'height'
  }

  def self.import_csv(product_file, fetim_file)
    products_text, products_sep = CsvTools.prep_csv(product_file, 'Artikelnummer')
    return nil unless products_text

    CSV.parse(products_text, :col_sep => products_sep, :headers => true, :skip_blanks => true, :converters => :all).each do |row|
      next if row.header_row?
        params = {}
        row.each {|k,v| params[COLUMNS[k]] = v if COLUMNS[k]}
        existing = Product.find_by_item_code params['item_code']
        if existing
          existing.attributes = params
          existing.status = 'active'
          existing.save
        else
          create params
        end
    end
  end

  PALLET_LENGTH = 1200
  PALLET_WIDTH = 800
  PALLET_HEIGHT = 800 - 160

  def determine_max_pallet
    return 1 unless length.present? && width.present? && height.present?
    return approx_boxes_in_layer * pallet_layers if PALLET_LENGTH * PALLET_WIDTH / (length * width) > 25
    self.max_pallet = boxes_in_layer(PALLET_LENGTH, PALLET_WIDTH) * pallet_layers
  end

  def pallet_layers
    [1, (PALLET_HEIGHT / self.height).floor].max
  end

  def approx_boxes_in_layer
    return [
      (PALLET_LENGTH / length).floor * (PALLET_WIDTH / width).floor,
      (PALLET_LENGTH / width).floor * (PALLET_WIDTH / length).floor
    ].max
  end

  def boxes_in_layer(x,y)
    return 0 if x < 0 || y < 0
    result_ar = [
      x >= length && y >= width ? boxes_in_layer(x-length, y) + boxes_in_layer(length, y-width) + 1 : 0,
      x >= width && y >= length ? boxes_in_layer(x-width, y) + boxes_in_layer(width, y-length) + 1 : 0,
      y >= length && x >= width ? boxes_in_layer(x, y-length) + boxes_in_layer(x-width, length) + 1 : 0,
      y >= width && x >= length ? boxes_in_layer(x, y-width) + boxes_in_layer(x-length, width) + 1 : 0
    ]
    result = result_ar.max
    result
  end

  def barcode
    Barby::EAN13.new(self.code_bars) if self.valid_barcode?
  end

  def valid_barcode?
    code_bars.present? && code_bars =~ /^[0-9]{13}$/
  end

  def delete!
    self.status = 'deleted'
    save
  end

end
