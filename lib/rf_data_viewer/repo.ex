defmodule RFDataViewer.Repo do
  use Ecto.Repo,
    otp_app: :rf_data_viewer,
    adapter: Ecto.Adapters.Postgres
end
