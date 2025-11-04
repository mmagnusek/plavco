class AddEmailToOmniAuthIdentities < ActiveRecord::Migration[8.0]
  def change
    add_column :omni_auth_identities, :email, :string

    OmniAuthIdentity.all.each do |identity|
      identity.update(email: identity.user.email_address)
    end

    change_column_null :omni_auth_identities, :email, false
  end
end
