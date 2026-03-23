defmodule RestaurantAccess.Repo do
  use Ecto.Repo,
    otp_app: :restaurant_access,
    adapter: Ecto.Adapters.Postgres
end
