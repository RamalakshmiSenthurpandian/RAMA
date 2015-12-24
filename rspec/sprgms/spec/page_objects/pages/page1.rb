module Service
	class Etest < SitePrism::Page
		set_url "http://e-test.me"
		element :ecommerce, "#ecommerce"
		element :test_withid, "#withid"
	end
end
