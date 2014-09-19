xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0", "xmlns:g" => "http://base.google.com/ns/1.0"){
  xml.channel{
    xml.title("#{current_store.domains.split(',').first.capitalize}")
    xml.link("http://#{current_store.domains.split(',').first.downcase}")
    xml.description("De Google Shopping Feed van #{current_store.domains.split(',').first.capitalize}")
    xml.language('nl')
    @products.each do |product|
      xml.item do
        xml.title product.name
        xml.description simple_format(product.description)
        xml.author Spree::Config[:site_url]
        xml.pubDate (product.available_on || product.created_at).strftime("%a, %d %b %Y %H:%M:%S %z")
        affiliate_id = CgConfig::FEED[:affiliate][:google]
        xml.link "#{product_url(product)}?aid=#{affiliate_id[current_store.code.to_sym]}"

        image = product.andand.images.andand.first || product.andand.variants.andand.collect(&:images).flatten.first
        xml.g :image_link, "#{request.protocol}#{request.host_with_port}#{image.attachment.url(:large)}" if image.present?

        xml.g :price, "#{product.original_price} EUR" # originele prijs
        xml.g :sale_price, "#{product.price} EUR" # aanbiedingsprijs
        xml.g :gtin, product.ean_code unless product.ean_code.blank?
        xml.g :color, product.property('color')
        xml.g :brand, product.property('brand')
        xml.g :quantity, 10
        xml.g :availability, 'in stock'
        xml.g :online_only, 'y'
        xml.g :product_type, product.taxons.where(is_brand: false).andand.first.andand.ancestors.andand.map{ |t| t.name }.andand.join(' > ')
        condition = product.available_on < 1.month.ago ? 'retail' : 'new'
        xml.g :condition, condition
        xml.g :id, product.id
        xml.g :shipping do
          xml.g :country, 'NL'
          xml.g :services, 'Standard'
          xml.g :price, '0.00'
        end
        xml.g :adult, 'TRUE'
      end
    end
  }
}
