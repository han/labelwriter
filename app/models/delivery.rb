require 'csv'
class Delivery < ActiveRecord::Base
  belongs_to :product

  validates :product_id, :purchase_order, :order_quantity, :presence => true

  def self.import_inbound_csv(file)
    return false unless file.present?
    csv = CSV.parse(file.read, :col_sep => ';', :headers => true, :skip_blanks => true)
    changed_deliveries = []
    Delivery.transaction do
      csv.each do |row|

        next if row.header_row?
        ship_date = Date.strptime(row['ShipDate'], "%d-%m-%y")
        po = row['DocNum']
        q = convert_to_i(row['OpenQty'])
        product = Product.find_by_item_code row['ItemCode']

        next unless product

        delivery = Delivery.find_by_purchase_order_and_shipped_at_and_product_id(po, ship_date, product.id)
        if delivery
          changed_deliveries << delivery.id if delivery.order_quantity != q
          delivery.update_attributes :order_quantity => q
        else
          delivery = create :product_id => product.id, :purchase_order => po, :order_quantity => q, :shipped_at => ship_date
          changed_deliveries << delivery.id
        end
      end
    end
    changed_deliveries
  end

  def self.import_outbound_csv(file)
    return false unless file.present?
    csv_text = file.read
    Rails.logger.info csv_text
    ar = csv_text.split("\r\n")
    Rails.logger.info ar.inspect
    ar = ar[1..-1]
    csv_text = ar.join("\n")
    Rails.logger.info "csv text: #{csv_text}"
    csv = CSV.parse(csv_text, :col_sep => ';', :headers => true)
    changed_deliveries = []
    Delivery.transaction do
      csv.each do |row|
        next if row.header_row?
        delivery_date = Date.strptime(row['Delivery Date'], "%Y-%m-%d")
        tour_number = row['Tour Number']
        po = row['Ordernr']
        order_qty = convert_to_i(row['Order. Qty'])
        actual_qty = convert_to_i(row['Act. Qty'])

        product = Product.find_by_item_code row['Item Number']
        next unless product
        Rails.logger.info "*** #{po} #{order_qty} #{actual_qty} -- item number : #{row['Item Number']}"

        # delivery = Delivery.find_by_purchase_order_and_product_id(po, product.id).last
        delivery = Delivery.where(:purchase_order => po).where(:product_id => product.id).order("id DESC").first
        Rails.logger.info "Delivery: #{delivery.inspect}"
        next unless delivery

        raise "Order Quantity inconsistent for delivery #{delivery.id} #{order_qty} != #{delivery.order_quantity}" if order_qty != delivery.order_quantity
        delivery.update_attributes :tour_number => tour_number, :actual_quantity => actual_qty, :delivered_at => delivery_date
        changed_deliveries << delivery.id if delivery.actual_quantity != delivery.order_quantity
      end
    end
    changed_deliveries
  end

  def self.convert_to_i(txt)
    return unless txt.present?
    txt.gsub('.','').split(',')[0].to_i
  end
end

# FESC => geen barcode
# FE.* => pallet label
# labels 2x

