require 'csv'
require 'csv_tools'

class Delivery < ActiveRecord::Base
  belongs_to :product

  attr_accessible :product_id, :purchase_order, :order_quantity, :actual_quantity, :shipped_at, :delivered_at, :tour_number

  validates :product_id, :purchase_order, :order_quantity, :presence => true

  def self.import_inbound_csv(file, user)
    return false unless file.present?
    inbound_text, sep = CsvTools.prep_csv(file, 'Mutatie')
    return nil unless inbound_text
    errors = {}
    changed_deliveries = {}
    Delivery.transaction do
      CSV.parse(inbound_text, :col_sep => sep, :headers => true, :skip_blanks => true).each do |row|

        next if row.header_row?
        ship_date = Date.strptime(row['ShipDate'], "%d-%m-%y")
        po = row['DocNum']
        q = convert_to_i(row['OpenQty'])
        product = Product.find_by_item_code row['ItemCode']

        next unless product

        delivery = Delivery.find_by_purchase_order_and_shipped_at_and_product_id(po, ship_date, product.id)
        if delivery
          changed_deliveries[delivery.id] = delivery if delivery.order_quantity != q
          delivery.update_attributes :order_quantity => q
        else
          delivery = create :product_id => product.id, :purchase_order => po, :order_quantity => q, :shipped_at => ship_date
          changed_deliveries[delivery.id] = delivery
        end
        (errors[delivery.id] ||= []) << "Order Quantity #{q} not consistent with per_pack_un (#{delivery.product.per_pack_un})" unless delivery.quantity_consistent?
      end
      DeliveryAudit.create :deliveries => changed_deliveries, :errors => errors, :user => user.id
    end
    changed_deliveries.keys
  end

  def self.import_outbound_csv(file, user)
    return false unless file.present?
    outbound_text, sep = CsvTools.prep_csv(file, 'Delivery Date')
    return nil unless outbound_text
    errors = {}
    changed_deliveries = {}
    Delivery.transaction do
      CSV.parse(outbound_text, :col_sep => sep, :headers => true, :skip_blanks => true).each do |row|
        next if row.header_row?
        delivery_date = Date.strptime(row['Delivery Date'], "%d-%m-%Y")
        tour_number = row['Tour Number']
        po = row['Ordernr']
        order_qty = convert_to_i(row['Order. Qty'])
        actual_qty = convert_to_i(row['Act. Qty'])

        product = Product.find_by_item_code row['Item Number']
        next unless product

        # delivery = Delivery.find_by_purchase_order_and_product_id(po, product.id).last
        delivery = Delivery.where(:purchase_order => po).where(:product_id => product.id).order("id DESC").first
        next unless delivery

        (errors[delivery.id] ||= []) << "Attempt to update order quantity from #{delivery.order_quantity} to #{order_qty}" if order_qty != delivery.order_quantity
        (errors[delivery.id] ||= []) << "Actual Quantity #{actual_qty} not consistent with per_pack_un (#{delivery.product.per_pack_un})" unless delivery.quantity_consistent?(actual_qty)

        delivery.attributes = {:tour_number => tour_number, :actual_quantity => actual_qty, :delivered_at => delivery_date}
        changed_deliveries[delivery.id] = delivery if delivery.changed?
        delivery.save!
      end
      DeliveryAudit.create :deliveries => changed_deliveries, :errors => errors, :user => user.id
    end
    changed_deliveries.keys
  end

  def quantity
    if actual_quantity.present? && actual_quantity > 0
      actual_quantity
    else
      order_quantity
    end
  end

  def num_boxes
    return 0 unless  product.per_pack_un.present?
    (1.0 * quantity / product.per_pack_un).ceil
  end

  def quantity_consistent?(q = quantity)
    return false unless product.per_pack_un.present?
    q % self.product.per_pack_un  == 0
  end

  def pallets_needed
    return 1 unless product.max_pallet.present?
    (1.0 * num_boxes / product.max_pallet).ceil
  end

  def self.convert_to_i(txt)
    return unless txt.present?
    txt.gsub('.','').split(',')[0].to_i
  end

  def boxes_for_pallet(pallet_no)
    [num_boxes - (pallet_no - 1) * product.max_pallet, product.max_pallet].min
  end

  def quantity_for_pallet(pallet_no)
    product.per_pack_un * boxes_for_pallet(pallet_no)
  end
end

# FESC => geen barcode
# FE.* => pallet label
# labels 2x

