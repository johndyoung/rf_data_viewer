defmodule RFDataViewerWeb.RFUnitsUnitLive do
  alias RFDataViewer.RFUnits
  use RFDataViewerWeb, :live_view

  def mount(%{"rf_unit_id" => unit_id} = _params, _session, socket) do
    unit = RFUnits.get_rf_unit!(unit_id)
    data = RFUnits.get_rf_unit_serial_numbers_with_counts(unit.id)

    {:ok, assign(socket, %{unit: unit, serial_numbers: data})}
  end

end
