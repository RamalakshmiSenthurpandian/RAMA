module Gree
	class Verify < SitePrism::Page
		set_url "http://e-test.me/ecommerce/checkout/cart/"
		element :update_cart, ".button2.btn-update"
	end
end
