defmodule RFDataViewer.RFUnitsTest do
  use RFDataViewer.DataCase

  alias RFDataViewer.RFUnits

  describe "rf_units" do
    alias RFDataViewer.RFUnits.RFUnit

    import RFDataViewer.RFUnitsFixtures

    @invalid_attrs %{name: nil, description: nil, manufacturer: nil}

    test "list_rf_units/0 returns all rf_units" do
      rf_unit = rf_unit_fixture()
      assert RFUnits.list_rf_units() == [rf_unit]
    end

    test "get_rf_unit!/1 returns the rf_unit with given id" do
      rf_unit = rf_unit_fixture()
      assert RFUnits.get_rf_unit!(rf_unit.id) == rf_unit
    end

    test "create_rf_unit/1 with valid data creates a rf_unit" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        manufacturer: "some manufacturer"
      }

      assert {:ok, %RFUnit{} = rf_unit} = RFUnits.create_rf_unit(valid_attrs)
      assert rf_unit.name == "some name"
      assert rf_unit.description == "some description"
      assert rf_unit.manufacturer == "some manufacturer"
    end

    test "create_rf_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RFUnits.create_rf_unit(@invalid_attrs)
    end

    test "create_rf_unit/0 name and manufacturer unique constraint" do
      rf_unit = rf_unit_fixture()

      diff_name = %{
        name: "#{rf_unit.name} diff",
        description: rf_unit.description,
        manufacturer: rf_unit.manufacturer
      }

      assert {:ok, %RFUnit{}} = RFUnits.create_rf_unit(diff_name)

      same_name = %{
        name: rf_unit.name,
        description: rf_unit.description,
        manufacturer: rf_unit.manufacturer
      }

      assert {:error, %Ecto.Changeset{}} = RFUnits.create_rf_unit(same_name)
    end

    test "update_rf_unit/2 with valid data updates the rf_unit" do
      rf_unit = rf_unit_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        manufacturer: "some updated manufacturer"
      }

      assert {:ok, %RFUnit{} = rf_unit} = RFUnits.update_rf_unit(rf_unit, update_attrs)
      assert rf_unit.name == "some updated name"
      assert rf_unit.description == "some updated description"
      assert rf_unit.manufacturer == "some updated manufacturer"
    end

    test "update_rf_unit/2 with invalid data returns error changeset" do
      rf_unit = rf_unit_fixture()
      assert {:error, %Ecto.Changeset{}} = RFUnits.update_rf_unit(rf_unit, @invalid_attrs)
      assert rf_unit == RFUnits.get_rf_unit!(rf_unit.id)
    end

    test "delete_rf_unit/1 deletes the rf_unit" do
      rf_unit = rf_unit_fixture()
      assert {:ok, %RFUnit{}} = RFUnits.delete_rf_unit(rf_unit)
      assert_raise Ecto.NoResultsError, fn -> RFUnits.get_rf_unit!(rf_unit.id) end
    end

    test "delete_rf_unit_by_id/1 deletes the rf_unit using the primary key" do
      rf_unit = rf_unit_fixture()
      assert {:ok, %RFUnit{}} = RFUnits.delete_rf_unit_by_id(rf_unit.id)
      assert_raise Ecto.NoResultsError, fn -> RFUnits.get_rf_unit!(rf_unit.id) end
    end

    test "change_rf_unit/1 returns a rf_unit changeset" do
      rf_unit = rf_unit_fixture()
      assert %Ecto.Changeset{} = RFUnits.change_rf_unit(rf_unit)
    end
  end

  describe "rf_unit_serial_numbers" do
    alias RFDataViewer.RFUnits.RFUnitSerialNumber

    import RFDataViewer.RFUnitsFixtures

    @invalid_attrs %{serial_number: nil}

    test "list_rf_unit_serial_numbers/0 returns all rf_unit_serial_numbers" do
      rf_unit_serial_number = rf_unit_serial_number_fixture()
      assert RFUnits.list_rf_unit_serial_numbers() == [rf_unit_serial_number]
    end

    test "get_rf_unit_serial_number!/1 returns the rf_unit_serial_number with given id" do
      rf_unit_serial_number = rf_unit_serial_number_fixture()
      assert RFUnits.get_rf_unit_serial_number!(rf_unit_serial_number.id) == rf_unit_serial_number
    end

    test "create_rf_unit_serial_number/1 with valid data creates a rf_unit_serial_number" do
      rf_unit = rf_unit_fixture()
      valid_attrs = %{serial_number: "some serial_number"}

      assert {:ok, %RFUnitSerialNumber{} = rf_unit_serial_number} =
               RFUnits.create_rf_unit_serial_number(rf_unit, valid_attrs)

      assert rf_unit_serial_number.serial_number == "some serial_number"
    end

    test "create_rf_unit_serial_number/1 with invalid data returns error changeset" do
      rf_unit = rf_unit_fixture()

      assert {:error, %Ecto.Changeset{}} =
               RFUnits.create_rf_unit_serial_number(rf_unit, @invalid_attrs)
    end

    test "update_rf_unit_serial_number/2 with valid data updates the rf_unit_serial_number" do
      rf_unit_serial_number = rf_unit_serial_number_fixture()
      update_attrs = %{serial_number: "some updated serial_number"}

      assert {:ok, %RFUnitSerialNumber{} = rf_unit_serial_number} =
               RFUnits.update_rf_unit_serial_number(rf_unit_serial_number, update_attrs)

      assert rf_unit_serial_number.serial_number == "some updated serial_number"
    end

    test "update_rf_unit_serial_number/2 with invalid data returns error changeset" do
      rf_unit_serial_number = rf_unit_serial_number_fixture()

      assert {:error, %Ecto.Changeset{}} =
               RFUnits.update_rf_unit_serial_number(rf_unit_serial_number, @invalid_attrs)

      assert rf_unit_serial_number == RFUnits.get_rf_unit_serial_number!(rf_unit_serial_number.id)
    end

    test "delete_rf_unit_serial_number/1 deletes the rf_unit_serial_number" do
      rf_unit_serial_number = rf_unit_serial_number_fixture()

      assert {:ok, %RFUnitSerialNumber{}} =
               RFUnits.delete_rf_unit_serial_number(rf_unit_serial_number)

      assert_raise Ecto.NoResultsError, fn ->
        RFUnits.get_rf_unit_serial_number!(rf_unit_serial_number.id)
      end
    end

    test "change_rf_unit_serial_number/1 returns a rf_unit_serial_number changeset" do
      rf_unit_serial_number = rf_unit_serial_number_fixture()
      assert %Ecto.Changeset{} = RFUnits.change_rf_unit_serial_number(rf_unit_serial_number)
    end
  end
end
