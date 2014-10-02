Spree::Product.class_eval do
  class << self
    def for_xml_feed(store_id)
      p = Spree::Product.arel_table
      v = Spree::Variant.arel_table
      s = Spree::Store.arel_table
      ps = Arel::Table.new(:spree_products_stores)
      query = p.join(ps).on(ps[:product_id].eq(p[:id])).join(s).on(ps[:product_id].eq(p[:id])).where(ps[:store_id].eq(store_id)).join(v).on(v[:product_id].eq(p[:id])).project(p[:id])
      products = Spree::Product.find_by_sql(query.to_sql).compact
    end
  end
end