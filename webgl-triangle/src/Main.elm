import Browser
import Browser.Events as Events

import Html exposing (Html)
import Html.Attributes exposing (width, height, style)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)

import WebGL

main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type alias Model = Float

type Msg = FrameUpdate Float

init : () -> (Model, Cmd Msg)
init () =
    (0.0, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FrameUpdate delta ->
            (model + delta, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions _ =
    Events.onAnimationFrameDelta FrameUpdate

view : Model -> Html Msg
view time =
    WebGL.toHtml
        [ width 400, height 300, style "display" "block" ]
        [ WebGL.entity vertexShader fragmentShader mesh { perspective = perspective (time / 1000) }
        ]

perspective : Float -> Mat4
perspective time =
    Mat4.mul
        (Mat4.makePerspective 45 1 0.01 100)
        (Mat4.makeLookAt (vec3 (4 * cos time) 0 (4 * sin time)) (vec3 0 0 0) (vec3 0 1 0))

type alias Vertex =
    { position : Vec3
    , color : Vec3
    }

mesh : WebGL.Mesh Vertex
mesh =
    WebGL.triangles
        [   ( Vertex (vec3 0 0 0) (vec3 1 0 0)
            , Vertex (vec3 1 1 0) (vec3 0 1 0)
            , Vertex (vec3 1 -1 0) (vec3 0 0 1)
            )
        ]

type alias Uniforms =
    { perspective : Mat4 
    }

vertexShader : WebGL.Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|
        attribute vec3 position;
        attribute vec3 color;

        uniform mat4 perspective;
        varying vec3 vcolor;

        void main() 
        {
            gl_Position = perspective * vec4(position, 1.0);
            vcolor = color;    
        }
    |]

fragmentShader : WebGL.Shader {} Uniforms { vcolor : Vec3 }
fragmentShader = 
    [glsl|
        precision mediump float;
        varying vec3 vcolor;

        void main()
        {
            gl_FragColor = vec4(vcolor, 1.0);
        }
    |]