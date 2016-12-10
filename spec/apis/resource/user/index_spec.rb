require 'rails_helper'

describe Api::V1::UsersController, '#index', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        5.times{ FactoryGirl.create(:user) }

        get api_v1_users_path, format: :json
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        5.times{ FactoryGirl.create(:user) }

        get api_v1_users_path, format: :json
      end

      it_returns_status(200)
      it_returns_collection_size(resource: 'users', size: 6)
      it_returns_collection_attributes(
        resource: 'users', attrs: [
          :id, :name, :email, :admin, :activated, :created_at, :updated_at
        ]
      )
      it_returns_no_collection_attributes(
        resource: 'users', attrs: [
          :foo
        ]
      )

      it_returns_collection_attribute_values(
        resource: 'users', model: proc{User.first!}, attrs: [
          :id, :name, :email, :admin, :activated, :created_at, :updated_at
        ], modifiers: {[:created_at, :updated_at] => proc{|i| i.iso8601}}
      )
      #it_follows_json_schema('regular/users')
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin_user
        5.times{ FactoryGirl.create(:user) }

        get api_v1_users_path, format: :json
      end

      it_returns_status(200)
      #it_follows_json_schema('admin/users')
    end
  end
end
