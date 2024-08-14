defmodule RFDataViewerWeb.RFUnitsManageLive do
  alias RFDataViewer.RFUnits
  use RFDataViewerWeb, :live_view

  def mount(_params, _session, socket) do
    rf_units = RFUnits.list_rf_units_with_counts()
    {:ok, assign(socket, :rf_units, rf_units)}
  end
end
