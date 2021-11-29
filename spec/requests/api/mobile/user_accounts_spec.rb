require 'spec_helper'

describe "Accounts API List" do
  let(:account_type1) { FactoryGirl.create :account_type }
  let(:account_type1_account_1) { FactoryGirl.create :account, account_type: account_type1 }
  let(:account_type1_account_2) { FactoryGirl.create :account, account_type: account_type1 }
  let(:account_type2) { FactoryGirl.create :account_type }
  let(:account_type2_account1) { FactoryGirl.create :account, account_type: account_type2 }
  let(:account_type2_account2) { FactoryGirl.create :account, account_type: account_type2 }
  let(:no_restriction_non_admin_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer", login: "no_restriction_user", business_group_security_type: 0, account_security_type: 0) }
  let(:user_restrict_to_default_coa_account_type1) { FactoryGirl.create :user, login: "user_restrict_to_default_coa_account_type1", account_security_type: 1, default_account_type: account_type1, default_account: account_type1_account_1 }

  let(:client) do
    OpenidConnect::OidcClient.create(name: 'client', grant_type: "authorization_code", system: false, oidc_scopes: scope)
  end
  let(:token) do
    OpenidConnect::OidcAccessToken.create(oidc_client: client, user: user, oidc_scopes: client.oidc_scopes)
  end

  subject do
    get path, headers: { 'Authorization' => "Bearer #{token.unhashed_token}", 'Accept' => 'application/json' }
  end
  
  context "Verified whether the User (non-admin) is able to see all the accounts when the billing security is set to No Account restriction" do     
    let(:scope) { OpenidConnect::OidcScope.where(name: 'core.accounting.read') }
    let(:user) { no_restriction_non_admin_user }
   
    
    let(:path) { "/api/accounts/user_accounts?user_id=#{no_restriction_non_admin_user.id}&account_type_id=#{account_type1.id}" } 

    it "lists filtered accounts" do
      subject { {'get' => path } }
      binding.pry
    end
  end

  # context "Verified whether the User (non-admin) is able to see all the accounts when the billing security is set to No Account restriction and without passing account tyoe id user can see all the accounts from all COA" do     
  #   let(:scope) { OpenidConnect::OidcScope.where(name: 'core.accounting.read') }
  #   let(:client) do
  #     OpenidConnect::OidcClient.create(name: 'client', grant_type: "authorization_code", system: false, oidc_scopes: scope)
  #   end
  #   let(:token) do
  #     OpenidConnect::OidcAccessToken.create(oidc_client: client, user: no_restriction_non_admin_user, oidc_scopes: client.oidc_scopes)
  #   end

  #   let(:path) { "/api/accounts/user_accounts?user_id=#{no_restriction_non_admin_user.id}" } 

  #   let(:params) { { } }

  #   it "lists filtered accounts" do
  #     subject
  #     binding.pry
  #   end
  # end

  # context "Verify whether the User is able to see only the selected COA details when the Non-admin User profile billing security is restricted to Default COA" do     
  #   let(:scope) { OpenidConnect::OidcScope.where(name: 'core.accounting.read') }
  #   let(:client) do
  #     OpenidConnect::OidcClient.create(name: 'client', grant_type: "authorization_code", system: false, oidc_scopes: scope)
  #   end
  #   let(:token) do
  #     OpenidConnect::OidcAccessToken.create(oidc_client: client, user: user_restrict_to_default_coa_account_type1, oidc_scopes: client.oidc_scopes)
  #   end

  #   let(:path) { "/api/accounts/user_accounts?user_id=#{user_restrict_to_default_coa_account_type1.id}&account_type_id=#{account_type1.id}" } 

  #   let(:params) { { } }

  #   it "lists filtered accounts" do
  #     subject
  #     binding.pry
  #     # expect(response).to be_success
  #     # expect(xml_response["accounts"].size).to eq(1)
  #   end
  # end
end
