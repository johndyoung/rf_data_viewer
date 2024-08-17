defmodule RFDataViewerWeb.FormHelper do
  import Phoenix.Component

  def assign_form(socket, name, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: name)

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
