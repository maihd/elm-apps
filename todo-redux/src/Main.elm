import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update 
        }

type VisibilityFilter
    = ShowAll
    | ShowActive
    | ShowComplete

type alias Todo =
    { text : String
    , complete : Bool
    }

type alias Model =
    { visibilityFilter : VisibilityFilter
    , todos : List Todo
    , input : String
    }

type Msg
    = SetVisibilityFilter VisibilityFilter
    | AddTodo String
    | ToggleTodo Int
    | InputTodoName String

init : Model
init = 
    { visibilityFilter = ShowAll
    , todos = []
    , input = ""
    }

update : Msg -> Model -> Model
update msg model =
    case msg of 
        SetVisibilityFilter filter ->
            { model | visibilityFilter = filter }

        AddTodo text ->
            { model | todos = List.append model.todos [ { text = text, complete = False } ], input = "" }

        ToggleTodo id ->
            { model | todos = List.indexedMap (\index todo -> if index == id then { text = todo.text, complete = not todo.complete } else todo) model.todos }

        InputTodoName input ->
            { model | input = input }

view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Todo list" ]
        , viewAddTodo model.input
        , viewTodos (getVisibleTodos model.todos model.visibilityFilter)
        , viewFooter model.visibilityFilter
        ]

viewAddTodo : String -> Html Msg
viewAddTodo currentInput =
    div []
        [ input [ value currentInput, onInput InputTodoName ] []
        , button [ onClick (AddTodo currentInput) ] [ text "Add" ]
        ]

viewTodos : List Todo -> Html Msg
viewTodos todos =
    ul []
        (List.indexedMap (\index todo -> viewTodo todo (onClick (ToggleTodo index))) todos)

viewTodo : Todo -> Attribute Msg -> Html Msg
viewTodo todo onClick =
    li [ style "text-decoration" (if todo.complete then "line-through" else "none"), onClick ]
        [ text todo.text ]

viewFooter : VisibilityFilter -> Html Msg
viewFooter filter =
    div []
        [ viewLink "Show All"       (filter == ShowAll)         (onClick (SetVisibilityFilter ShowAll))
        , viewLink "Show Active"    (filter == ShowActive)      (onClick (SetVisibilityFilter ShowActive))
        , viewLink "Show Complete"  (filter == ShowComplete)    (onClick (SetVisibilityFilter ShowComplete))
        ]

viewLink : String -> Bool -> Attribute Msg -> Html Msg
viewLink content active onClick =
    if active then
        span [] [ text content ]
    else
        button [ onClick ] [ text content ] 

getVisibleTodos : List Todo -> VisibilityFilter -> List Todo
getVisibleTodos todos visibilityFilter =
    case visibilityFilter of
        ShowAll         -> todos
        ShowActive      -> List.filter (\todo -> not todo.complete) todos
        ShowComplete    -> List.filter (\todo -> todo.complete)     todos