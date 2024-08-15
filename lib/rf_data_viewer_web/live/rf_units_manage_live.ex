defmodule RFDataViewerWeb.RFUnitsManageLive do
  use RFDataViewerWeb, :live_view
  alias RFDataViewer.RFUnits.RFUnit
  alias RFDataViewer.RFUnits

  def mount(_params, _session, socket) do
    rf_units = RFUnits.list_rf_units_with_counts()
    changeset = RFUnits.change_rf_unit(%RFUnit{})

    {:ok,
     socket
     |> assign(%{
       rf_units: rf_units,
       check_errors: false
     })
     |> assign_form(changeset)}
  end

  def toggle_create_ui_state() do
    JS.toggle(to: "#create-new-unit-form")
    |> JS.toggle_class("blur-[2px]", to: "#unit-table")
  end

  def close_create_ui_state() do
    JS.hide(to: "#create-new-unit-form")
    |> JS.remove_class("blur-[2px]", to: "#unit-table")
  end

  def handle_event("save", %{"unit" => unit_params}, %{assigns: %{rf_units: units}} = socket) do
    case RFUnits.create_rf_unit(unit_params) do
      {:ok, unit} ->
        # entries from RF.Units.list_rf_units_with_counts/0 are of the form {unit, sn_count, ts_count, ds_count, data_count}
        unit_tuple = {unit, 0, 0, 0, 0}
        empty_changeset = RFUnits.change_rf_unit(%RFUnit{})

        {:noreply,
         socket
         |> assign(:rf_units, [unit_tuple | units])
         |> assign_form(empty_changeset)
         |> push_event("rf-unit-created", %{id: unit.id})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"unit" => unit_params}, socket) do
    changeset = RFUnits.change_rf_unit(%RFUnit{}, unit_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "unit")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
