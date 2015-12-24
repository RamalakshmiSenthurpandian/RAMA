require 'spec_helper'
module Server
	step 'I am on the etest page' do 
		#visit 'http://e-test.me/'
		obj=Service::Etest.new
		obj.load
		#obj.ecommerce.click
        sleep 5
    end

    step 'I am on product page and click the product aviator sunglass' do
    	obj1=Services::Ecommerce.new
        obj1.load
        #obj1.products
        obj1.products.Aviator_Sunglasses.click
        sleep 10
    end
    step 'I am on cart page and click the add to cart button' do
        obj2=Red::Add.new
        obj2.load
        obj2.add_to_cart.click
        sleep 4
    end
    step 'I am on update page and click update to cart' do
        obj3=Gree::Verify.new
        obj3.load
        obj3.update_cart.click
        sleep 10
    end
end
RSpec.configure{|c| c.include Server}
