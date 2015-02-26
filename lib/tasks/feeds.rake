include ActionView::Helpers::TextHelper

namespace :feeds do
  desc "create google feed"
  task google: :environment do
    google_product_category = {
      'condooms' => 'Gezondheid & Persoonlijke verzorging > Gezondheidszorg > Voorbehoedsmiddelen > Condooms',
      'glijmiddel' => 'Gezondheid & persoonlijke verzorging > Persoonlijke verzorging > Glijmiddelen',
      'drogist' => 'Gezondheid & Persoonlijke verzorging > Gezondheidszorg > Voorbehoedsmiddelen',
      'massage' => 'Gezondheid & Persoonlijke verzorging &gt; Persoonlijke verzorging > Massage &amp; Ontspanning',
      'zwangerschapstesten' => 'Gezondheid & Persoonlijke verzorging > Gezondheidszorg > Zwangerschapstests',
      'sextoys' => 'Volwassenen > Erotisch > Seksspeeltjes',
      'overig' => 'Volwassenen > Erotisch'
    }

    Spree::Store.all.each do |store|

      file = File.new(Rails.root.join(CgConfig::PRODUCT_FEEDS[:asset_path],"#{store.code}_google.xml"), "w")

      xml = Builder::XmlMarkup.new(target: file, indent: 2)
      xml.instruct! :xml, :version=>"1.0"
      xml.rss(:version=>"2.0", "xmlns:g" => "http://base.google.com/ns/1.0"){
        xml.channel{
          xml.title("#{store.domains.split(',').first.capitalize}")
          xml.link("http://#{store.domains.split(',').first.downcase}")
          xml.description("De Google Shopping Feed van #{store.domains.split(',').first.capitalize}")
          xml.language('nl')
          Spree::Product.by_store(store).active.available.uniq.each do |product|
            xml.item do
              xml.title product.name(:nl) || product.name(:en)
              xml.description simple_format(product.description)
              xml.author store.domains.split(',').first.capitalize
              xml.pubDate (product.available_on || product.created_at).strftime("%a, %d %b %Y %H:%M:%S %z")
              affiliate_id = CgConfig::FEED[:affiliate][:google]
              xml.link "http://#{store.domains.split(',').first.downcase}/#{product.permalink}?aid=#{affiliate_id[store.code.to_sym]}"

              image = product.andand.images.andand.first || product.andand.variants.andand.collect(&:images).flatten.first
              xml.g :image_link, "http://#{store.domains.split(',').first.downcase}/#{image.attachment.url(:large)}" if image.present?

              xml.g :price, "#{product.original_price(store)}" # originele prijs
              xml.g :sale_price, "#{product.price}" # aanbiedingsprijs
              if product.has_variants?
                gtin = product.variants.first.andand.ean_code.andand.strip.blank? ? '0' : product.variants.first.andand.ean_code.andand.strip
              else
                gtin = product.ean_code.andand.strip.blank? ? '0' : product.ean_code.andand.strip
              end
              xml.g :gtin, gtin
              xml.g :color, product.property('color').andand.strip unless product.property('color').andand.strip.blank?
              xml.g :brand, product.property('brand').andand.strip
              xml.g :quantity, 10
              xml.g :availability, 'in stock'
              xml.g :online_only, 'y'
              xml.g :product_type, product.taxons.by_store(store).where(is_brand: false).andand.first.andand.ancestors.andand.map{ |t| t.name }.andand.push(product.taxons.by_store(store).where(is_brand: false).andand.first.andand.name).andand.join(' > ')

              product_taxon = product.taxons.by_store(store).where(is_brand: false).andand.first.andand.name.andand.downcase || 'overig'
              if product.google_shopping_category.present?
                xml.g :google_product_category, product.google_shopping_category
              else
                xml.g :google_product_category, google_product_category.has_key?(product_taxon) ? google_product_category[product_taxon] : google_product_category['overig']
              end

              xml.g :condition, 'new'
              xml.g :id, product.id
              xml.g :shipping
              xml.g :adult, product.adult ? 'TRUE' : 'FALSE'
            end
          end
        }
      }
    end
  end

  desc "Create beslist feed"
  task beslist: :environment do
    Spree::Store.all.each do |store|

      # TODO:: This should be written to a tmp file so we don't overwrite the current xml
      file = File.new(Rails.root.join(CgConfig::PRODUCT_FEEDS[:asset_path],"#{store.code}_beslist.xml"), "w")

      xml = Builder::XmlMarkup.new(target: file, indent: 2)
      xml.instruct! :xml, :version=>"1.0"
      xml.root{
        Spree::Product.by_store(store).active.available.uniq.each do |product|
          xml.Product{
            xml.Titel product.name(:nl) || product.name(:en)
            if product.beslist_category.present?
              xml.Category product.beslist_category
            else
              xml.Categorie product.taxons.by_store(store).where(is_brand: false).andand.first.andand.ancestors.andand.map{ |t| t.name }.andand.push(product.taxons.by_store(store).where(is_brand: false).andand.first.andand.name).andand.join('/')
            end
            xml.Merk product.property('brand').andand.strip
            xml.Omschrijving simple_format(product.description(store))

            affiliate_id = product.affiliate_id || CgConfig::FEED[:affiliate][:beslist][store.code.to_sym]
            xml.Deeplink "http://#{store.domains.split(',').first.downcase}/#{product.permalink}?aid=#{affiliate_id}&utm_source=beslistnl&utm_medium=cpa&utm_campaign=beslist-CPA"

            image = product.andand.images.andand.first || product.andand.variants.andand.collect(&:images).flatten.first
            xml.tag! 'Image-locatie', "http://#{store.domains.split(',').first.downcase}/#{image.attachment.url(:large)}" if image.present?
            xml.Portokosten '0'
            xml.Levertijd '1-3 werkdagen'
            ean_code = product.ean_code.andand.strip.blank? ? '{leeg}' : product.ean_code.andand.strip
            xml.EAN ean_code

            xml.Prijs "#{product.price} EUR" # aanbiedingsprijs
            xml.Winkelproductcode product.id
            xml.Kleur Spree.t(product.property('color').to_sym) unless product.property('color').blank?
          }
        end
      }
    end
  end
end