module Coupamethods
	def logindetails
		obj=Coupa::Coupahome.new
		obj.load
		obj.user_login.set "CoupaSupport"
		obj.user_password.set "CoupaSupport1"
		obj.signin.click

		obj1=Server1::Invoice.new
	    obj1.invoice.click

	    obj2=Coupa5::Createinvoice.new
	    obj2.create_button.click

	    @obj3=Coupa3::Credit.new
	    @obj3.type.supplier.set "Accenture"
	    find('.ui-autocomplete-row.ui-corner-all', :visible=>true).click
        @obj3.type.invoice.set "56784996263465676"
        @obj3.type.invoice_payment_term_id.select "Net 15"
        
        obj4=Coupa8::Accounting.new
        obj4.type1.account.select "Ace Corporate"
	    obj4.type1.remit.click

	    obj5=Coupa9::Choose.new
	    obj5.choose.choosebutton.click

	    obj6=Coupa12::Description.new
	    obj6.descrip.description.set "delllaptop"
        obj6.descrip.quantity.set "120"
        obj6.descrip.uom.select "Weight"
        obj6.descrip.price.set "1200000"
        obj6.descrip.imagback.click
        obj6.descrip.accenture.click 
        
        @obj3.type.submit.click
        sleep 20
	end
	

end
RSpec.configure{|c| c.include Coupamethods}	