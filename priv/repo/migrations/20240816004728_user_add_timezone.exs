defmodule RFDataViewer.Repo.Migrations.UserAddTimezone do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :timezone, :string, null: false, default: "America/New_York"
    end

    execute "UPDATE users SET timezone = 'America/New_York'"
  end
end
