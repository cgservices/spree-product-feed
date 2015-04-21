Deface::Override.new(
    :virtual_path   => "spree/admin/products/_form",
    :name           => "add_shopping_feed_fields",
    :insert_bottom  => "[data-hook='admin_product_form_left']",
    :partial        => "spree/admin/products/shopping_feed_fields.html",
    :disabled       => false
)
