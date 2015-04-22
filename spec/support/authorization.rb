shared_context 'authorization' do
  let(:authorization_role) {nil}

  before {current_user.update_column :role, authorization_role if authorization_role.present?}

  context 'unauthorized' do
    User::ROLES.each do |role|
      context role do
        let(:authorization_role) {role}

        describe 'response' do
          subject {response}

          it {should have_http_status(:redirect) unless role == authorized_role}
          it {should redirect_to(root_path) unless role == authorized_role}
        end

        describe 'flash' do
          it {should set_flash[:alert].to('You are not authorized to view this page.') unless role == authorized_role}
        end
      end
    end
  end
end
