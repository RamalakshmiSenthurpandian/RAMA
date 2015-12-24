module Server1
	class Invoice <SitePrism::Page
		element :invoice, 'a[href*="/invoices"]', text: 'Invoices', visible: true
		
 	
	end
end