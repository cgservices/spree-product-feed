xml.instruct! :xml, :version=>"1.0"
xml.root{
  @products.each do |product|
    xml.product do
      xml.Titel product.name
      xml.Categorie product.taxons.by_store(current_store).where(is_brand: false).andand.first.andand.ancestors.andand.map{ |t| t.name }.andand.push(product.taxons.by_store(current_store).where(is_brand: false).andand.first.andand.name).andand.join('/')
      xml.Merk product.property('brand').andand.strip
      xml.Omschrijving simple_format(product.description)

      affiliate_id = CgConfig::FEED[:affiliate][:beslist]
      xml.Deeplink "#{product_url(product)}?aid=#{affiliate_id[current_store.code.to_sym]}&utm_source=beslistnl&utm_medium=cpa&utm_campaign=beslist-CPA"

      image = product.andand.images.andand.first || product.andand.variants.andand.collect(&:images).flatten.first
      xml.tag! 'Image-locatie', "#{request.protocol}#{request.host_with_port}#{image.attachment.url(:large)}" if image.present?
      xml.Portokosten '0.00'
      xml.Levertijd '1-3 werkdagen'
      ean_code = product.ean_code.andand.strip.blank? ? '{leeg}' : product.ean_code.andand.strip
      xml.EAN ean_code

      xml.Prijs "#{product.price(current_store)} EUR" # aanbiedingsprijs
      xml.Winkelproductcode product.id
      xml.Kleur Spree.t(product.property('color').to_sym) unless product.property('color').blank?


    end
  end
}