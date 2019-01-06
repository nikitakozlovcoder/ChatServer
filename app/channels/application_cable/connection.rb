module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if request.params['token'] && (id = User.get_id_from_token(request.params['token'])) && id != -1
          User.find(id)
        else
          reject_unauthorized_connection
        end
      end
  end
end
