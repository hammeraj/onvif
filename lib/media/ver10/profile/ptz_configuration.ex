defmodule Onvif.Media.Ver10.Profile.PtzConfiguration do
  @moduledoc """
  Optional configuration of the pan tilt zoom unit.
  """

  use Ecto.Schema

  embedded_schema do
    field(:reference_token, :string)
    field(:name, :string)
    field(:use_count, :integer)
    field(:move_ramp, :integer)
    field(:preset_ramp, :integer)
    field(:preset_tour_ramp, :integer)
    field(:node_token, :string)
    field(:default_absolute_pant_tilt_position_space, :string)
    field(:default_absolute_zoom_position_space, :string)
    field(:default_relative_pan_tilt_translation_space, :string)
    field(:default_relative_zoom_translation_space, :string)
    field(:default_continuous_pan_tilt_velocity_space, :string)
    field(:default_continuous_zoom_velocity_space, :string)
    field(:default_ptz_timeout, :string)

    embeds_one :default_ptz_speed, DefaultPtzSpeed do
      field(:pan_tilt, :string)
      field(:zoom, :string)
    end

    embeds_one :pan_tilt_limits, PanTiltLimits do
      embeds_one :range, Range do
        field(:uri, :string)

        embeds_one :x_range, XRange do
          field(:min, :float)
          field(:max, :float)
        end

        embeds_one :y_range, YRange do
          field(:min, :float)
          field(:max, :float)
        end
      end
    end

    embeds_one :zoom_limits, ZoomLimits do
      embeds_one :range, Range do
        field(:uri, :string)

        embeds_one :x_range, XRange do
          field(:min, :float)
          field(:max, :float)
        end
      end
    end

    embeds_one :extension, Extension do
      embeds_one :pt_control_direction, PtControlDirection do
        embeds_one :e_flip, EFlip do
          field(:mode, Ecto.Enum, values: [on: "ON", off: "OFF", extended: "Extended"])
        end

        embeds_one :reverse, Reverse do
          field(:mode, Ecto.Enum,
            values: [on: "ON", off: "OFF", auto: "AUTO", extended: "Extended"]
          )
        end
      end
    end
  end
end
