Spree::Product.class_eval do

  attr_accessible :google_shopping_category, :beslist_category, :adult

  def self.to_csv
    CSV.generate do |csv|
      csv << %w(id google_category beslist_category adult ean_code beslist_aid)
      all.each do |product|
        affiliate_name = Spree::Affiliate.find_by_id(product.affiliate_id).present? ? Spree::Affiliate.find_by_id(product.affiliate_id).name : ''
        csv << [product.id, product.google_shopping_category, product.beslist_category, product.adult.blank? ? 0 : product.adult, product.ean_code, affiliate_name]
      end
    end
  end
end