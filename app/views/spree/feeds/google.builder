google_product_category = {
  'condooms' => 'Gezondheid & Persoonlijke verzorging > Gezondheidszorg > Voorbehoedsmiddelen > Condooms',
  'glijmiddel' => 'Gezondheid & persoonlijke verzorging > Persoonlijke verzorging > Glijmiddelen',
  'drogist' => 'Gezondheid & Persoonlijke verzorging > Gezondheidszorg > Voorbehoedsmiddelen',
  'massage' => 'Gezondheid & Persoonlijke verzorging &gt; Persoonlijke verzorging > Massage &amp; Ontspanning',
  'zwangerschapstesten' => 'Gezondheid & Persoonlijke verzorging > Gezondheidszorg > Zwangerschapstests',
  'sextoys' => 'Volwassenen > Erotisch > Seksspeeltjes',
  'overig' => 'Volwassenen > Erotisch'
}

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

        xml.g :price, "#{product.original_price}" # originele prijs
        xml.g :sale_price, "#{product.price}" # aanbiedingsprijs
        gtin = product.ean_code.andand.strip.blank? ? '0' : product.ean_code.andand.strip
        xml.g :gtin, gtin
        xml.g :color, product.property('color').andand.strip
        xml.g :brand, product.property('brand').andand.strip
        xml.g :quantity, 10
        xml.g :availability, 'in stock'
        xml.g :online_only, 'y'
        xml.g :product_type, product.taxons.by_store(current_store).where(is_brand: false).andand.first.andand.ancestors.andand.map{ |t| t.name }.andand.push(product.taxons.by_store(current_store).where(is_brand: false).andand.first.andand.name).andand.join(' > ')

        product_taxon = product.taxons.by_store(current_store).where(is_brand: false).andand.first.andand.name.andand.downcase || 'overig'
        xml.g :google_product_category, google_product_category.has_key?(product_taxon) ? google_product_category[product_taxon] : google_product_category['overig']

        xml.g :condition, 'new'
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
