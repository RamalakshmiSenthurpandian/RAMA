module Coupa
	class Coupahome < SitePrism::Page
		set_url "https://dashmaster14-1-0.coupadev.com/sessions/new"
		element :user_login, "#user_login"
		element :user_password, "#user_password"
		element :signin, ".button"
	end
end
