defmodule RFDataViewer.Repo.Migrations.AlterHelper do
  @moduledoc """
    Helper functions to rename tables, primary keys, constraints, etc.

    courtesy of https://gist.github.com/fuelen
    https://gist.github.com/wosephjeber/42472d6522d03161d710d5adb3dc3534?permalink_comment_id=3612737#gistcomment-3612737
  """
  import Ecto.Migration

  def rename_fkey_table(from: from_table_name, to: to_table_name, field: field) do
    from_fkey = build_identifier(from_table_name, field, :fkey)
    to_fkey = build_identifier(to_table_name, field, :fkey)

    rename_constraint(from_table_name, from_fkey, to_fkey)
  end

  def rename_pkey_table(from: from_table_name, to: to_table_name) do
    from_pkey = build_identifier(from_table_name, nil, :pkey)
    to_pkey = build_identifier(to_table_name, nil, :pkey)

    rename_constraint(from_table_name, from_pkey, to_pkey)
  end

  def rename_seq_table(from: from_table_name, to: to_table_name, field: field) do
    to_seq = build_identifier(to_table_name, field, :seq)
    from_seq = build_identifier(from_table_name, field, :seq)

    execute(
      "ALTER SEQUENCE #{from_seq} RENAME TO #{to_seq};",
      "ALTER SEQUENCE #{to_seq} RENAME TO #{from_seq};"
    )
  end

  def rename_index_table(from: from_table_name, to: to_table_name, fields: fields) do
    to_index = build_identifier(to_table_name, fields, :index)
    from_index = build_identifier(from_table_name, fields, :index)

    execute(
      """
      ALTER INDEX #{from_index} RENAME TO #{to_index};
      """,
      """
      ALTER INDEX #{to_index} RENAME TO #{from_index};
      """
    )
  end

  def rename_constraint(table, from, to) do
    execute(
      """
      ALTER TABLE #{table} RENAME CONSTRAINT "#{from}" TO "#{to}";
      """,
      """
      ALTER TABLE #{table} RENAME CONSTRAINT "#{to}" TO "#{from}";
      """
    )
  end

  @max_identifier_length 63
  defp build_identifier(table_name, field_or_fields, ending) do
    ([table_name] ++ List.wrap(field_or_fields) ++ List.wrap(ending))
    |> Enum.join("_")
    |> String.slice(0, @max_identifier_length)
  end
end
