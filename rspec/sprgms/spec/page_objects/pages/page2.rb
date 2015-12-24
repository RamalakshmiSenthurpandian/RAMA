require './spec/page_objects/sections/section1.rb'
module Services
	class Ecommerce < SitePrism::Page
		set_url "http://e-test.me/ecommerce/accessories/eyewear.html"
        #click_link('http://e-test.me/ecommerce/accessories/eyewear.html')
        section :products, Ser::ShopSection ,".products-grid.products-grid--max-4-col.first.last.odd"
	end
end