defmodule Onvif.PTZ.GetNodesTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  alias Onvif.PTZ.Schemas.PTZNode
  alias Onvif.Schemas.FloatRange

  describe "GetNodes/1" do
    test "get ptz nodes" do
      xml_response = File.read!("test/ptz/fixtures/get_nodes_success.xml")

      device = Onvif.Factory.device()

      Mimic.expect(Tesla, :request, fn _client, _opts ->
        {:ok, %{status: 200, body: xml_response}}
      end)

      {:ok, response} = Onvif.PTZ.GetNodes.request(device)

      assert response == [
               %PTZNode{
                 token: "PTZNodeToken",
                 fixed_home_position: nil,
                 geo_move: nil,
                 name: "PTZNode",
                 supported_ptz_spaces: %PTZNode.SupportedPTZSpaces{
                   absolute_pan_tilt_position_space: %Onvif.PTZ.Schemas.Space2DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/PanTiltSpaces/PositionGenericSpace",
                     x_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     },
                     y_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     }
                   },
                   absolute_zoom_position_space: %Onvif.PTZ.Schemas.Space1DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/ZoomSpaces/PositionGenericSpace",
                     x_range: %FloatRange{
                       min: 0.0,
                       max: 1.0
                     }
                   },
                   relative_pan_tilt_translation_space: %Onvif.PTZ.Schemas.Space2DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/PanTiltSpaces/TranslationGenericSpace",
                     x_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     },
                     y_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     }
                   },
                   relative_zoom_translation_space: %Onvif.PTZ.Schemas.Space1DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/ZoomSpaces/TranslationGenericSpace",
                     x_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     }
                   },
                   continuous_pan_tilt_velocity_space: %Onvif.PTZ.Schemas.Space2DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/PanTiltSpaces/VelocityGenericSpace",
                     x_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     },
                     y_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     }
                   },
                   continuous_zoom_velocity_space: %Onvif.PTZ.Schemas.Space1DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/ZoomSpaces/VelocityGenericSpace",
                     x_range: %FloatRange{
                       min: -1.0,
                       max: 1.0
                     }
                   },
                   pan_tilt_speed_space: %Onvif.PTZ.Schemas.Space1DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/PanTiltSpaces/GenericSpeedSpace",
                     x_range: %FloatRange{
                       min: 0.0,
                       max: 1.0
                     }
                   },
                   zoom_speed_space: %Onvif.PTZ.Schemas.Space1DDescription{
                     uri: "http://www.onvif.org/ver10/tptz/ZoomSpaces/ZoomGenericSpeedSpace",
                     x_range: %FloatRange{
                       min: 0.0,
                       max: 1.0
                     }
                   }
                 },
                 maximum_number_of_presets: 300,
                 home_supported: true,
                 auxiliary_commands: [
                   "focusout",
                   "focusin",
                   "autofocus",
                   "resetfocus",
                   "irisout",
                   "irisin",
                   "auto",
                   "lightoff",
                   "lighton",
                   "brushoff",
                   "brushon"
                 ],
                 extension: %PTZNode.Extension{
                   supported_preset_tour:
                     %Onvif.PTZ.Schemas.PTZNode.Extension.SupportedPresetTour{
                       maximum_number_of_preset_tours: 8,
                       ptz_preset_tour_operation: ["Start"]
                     }
                 }
               }
             ]
    end
  end
end
