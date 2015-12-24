module Coupa4
	class InvoiceSection < SitePrism::Section
	    element :supplier, "#invoice_supplier_search"
		element :invoice, "#invoice_invoice_number"
		#element :account, "#invoice_account_type_id"
		element :invoice_payment_term_id, "#invoice_payment_term_id"
		element :submit, "#update_invoice"


	end
end
 