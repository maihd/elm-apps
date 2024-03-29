module Main exposing (..)

import Browser
import Browser.Dom as Dom

import Html exposing (..)
import Html.Lazy exposing (..)
import Html.Keyed as Keyed
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as Json
import Task

main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type alias Model =
    { entries : List Entry
    , field : String
    , uid : Int
    , visibility : String
    }

type alias Entry =
    { description : String
    , completed : Bool
    , editing : Bool
    , id : Int
    }

emptyModel : Model
emptyModel = 
    { entries = []
    , visibility = "All"
    , field = ""
    , uid = 0
    }

newEntry : String -> Int -> Entry
newEntry description id = 
    { description = description
    , completed = False
    , editing = False
    , id = id
    }

init : () -> (Model, Cmd Msg)
init maybeModel =
    ( emptyModel
    , Cmd.none
    )

type Msg
    = NoOp
    | UpdateField String
    | EditingEntry Int Bool
    | UpdateEntry Int String
    | Add
    | Delete Int
    | DeleteComplete
    | Check Int Bool
    | CheckAll Bool
    | ChangeVisibility String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)

        Add ->
            ({ model
                | uid = model.uid + 1
                , field = ""
                , entries = 
                    if String.isEmpty model.field then
                        model.entries
                    else
                        model.entries ++ [ newEntry model.field model.uid ]
             }
            , Cmd.none
            )

        UpdateField text ->
            ({ model | field = text }, Cmd.none)

        EditingEntry id isEditing ->
            let 
                updateEntry t = 
                    if t.id == id then
                        { t | editing = isEditing }
                    else
                        t
                
                focus =
                    Dom.focus ("todo-" ++ String.fromInt id)
            in
                ( { model | entries = List.map updateEntry model.entries }
                , Task.attempt (\_ -> NoOp) focus
                )

        UpdateEntry id task ->
            let 
                updateEntry t =
                    if t.id == id then
                        { t | description = task }
                    else
                        t
            in
                ( { model | entries = List.map updateEntry model.entries }
                , Cmd.none
                )

        Delete id ->
            ( { model | entries = List.filter (\t -> t.id /= id) model.entries }
            , Cmd.none
            )

        DeleteComplete ->
            ( { model | entries = List.filter (not << .completed) model.entries }
            , Cmd.none
            )

        Check id isCompleted ->
            let
                updateEntry t = 
                    if t.id == id then
                        { t | completed = isCompleted }
                    else
                        t
            in 
                ( { model | entries = List.map updateEntry model.entries }
                , Cmd.none
                )

        CheckAll isCompleted ->
            let
                updateEntry t =
                    { t | completed = isCompleted }
            in
                ( { model | entries = List.map updateEntry model.entries }
                , Cmd.none
                )

        ChangeVisibility visibility ->
            ( { model | visibility = visibility }
            , Cmd.none
            )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

view : Model -> Browser.Document Msg
view model = 
    { title = "Elm * TodoMVC"
    , body = [ viewMain model ]
    }

viewMain : Model -> Html Msg
viewMain model =
    div [ class "todomvc-wrapper"
        , style "visibility" "hidden"
        ]
        [ section [ class "todoapp" ]
            [ lazy viewInput model.field 
            , lazy2 viewEntries model.visibility model.entries
            , lazy2 viewControls model.visibility model.entries 
            ]
        , infoFooter
        ]

viewInput : String -> Html Msg
viewInput task =
    header
        [ class "header" ]
        [ h1 [] [ text "Todos" ]
        , input
            [ class "new-todo"
            , placeholder "What needs to be done?"
            , autofocus True
            , value task
            , name "newTodo"
            , onInput UpdateField
            , onEnter Add 
            ]
            []
        ]

onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not ENTER"
    in
        on "keydown" (Json.andThen isEnter keyCode)

viewEntries : String -> List Entry -> Html Msg
viewEntries visibility entries =
    let
        isVisible todo =
            case visibility of
                "Completed" ->
                    todo.completed

                "Active" ->
                    not todo.completed

                _ ->
                    True

        allCompleted =
            List.all .completed entries

        cssVisibility = 
            if List.isEmpty entries then
                "hidden"
            else
                "visible"
    in
        section
            [ class "main"
            , style "visibility" cssVisibility 
            ]
            [ input 
                [ class "toggle-all"
                , type_ "checkbox"
                , name "toggle"
                , checked allCompleted 
                , onClick (CheckAll (not allCompleted))
                ]
                []
            , label
                [ for "toggle-all" ]
                [ text "Mark all as complete" ]
            , Keyed.ul [ class "todo-list" ] <|
                List.map viewKeyedEntry (List.filter isVisible entries)
            ]
    
viewKeyedEntry : Entry -> (String, Html Msg)
viewKeyedEntry todo =
    (String.fromInt todo.id, lazy viewEntry todo)

viewEntry : Entry -> Html Msg
viewEntry todo =
    li
        [ classList [ ("completed", todo.completed), ("editing", todo.editing) ] ]
        [ div
            [ class "view" ]
            [ input 
                [ class "toggle" 
                , type_ "checkbox"
                , checked todo.completed
                , onClick (Check todo.id (not todo.completed))
                ]
                []
            , label 
                [ onDoubleClick (EditingEntry todo.id True) ]
                [ text todo.description ]
            , button 
                [ class "destroy" 
                , onClick (Delete todo.id)
                ]
                []
            ]
        , input 
            [ class "edit"
            , value todo.description 
            , name "title"
            , id ("todo-" ++ String.fromInt todo.id)
            , onInput (UpdateEntry todo.id)
            , onBlur (EditingEntry todo.id False)
            , onEnter (EditingEntry todo.id False)
            ]
            []
        ]

viewControls : String -> List Entry -> Html Msg
viewControls visibility entries =
    let 
        entriesCompleted = 
            List.length (List.filter .completed entries)

        entriesLeft =
            (List.length entries) - entriesCompleted
    in
        footer 
            [ class "footer"
            , hidden (List.isEmpty entries)
            ]
            [ lazy viewControlsCount entriesLeft
            , lazy viewControlsFilters visibility
            , lazy viewControlsClear entriesCompleted
            ]

viewControlsCount : Int -> Html Msg
viewControlsCount entriesLeft = 
    let 
        item = 
            if entriesLeft == 1 then
                " item"
            else
                " items"
    in
        span
            [ class "todo-count" ]
            [ strong [] [ text (String.fromInt entriesLeft) ]
            , text (item ++ "left")
            ]

viewControlsFilters : String -> Html Msg
viewControlsFilters visibility =
    ul  
        [ class "filters" ]
        [ visibilitySwap "/#/" "All" visibility
        , text " "
        , visibilitySwap "/#/active" "Active" visibility
        , text " "
        , visibilitySwap "/#/completed" "Completed" visibility
        ]

visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
    li
        [ onClick (ChangeVisibility visibility) ]
        [ a [ href uri, classList [ ("selected", visibility == actualVisibility) ] ]
            [ text visibility ]
        ]

viewControlsClear : Int -> Html Msg
viewControlsClear entriesCompleted = 
    button
        [ class "clear-completed"
        , hidden (entriesCompleted == 0)
        , onClick DeleteComplete
        ]
        [ text ("Clear completed (" ++ String.fromInt entriesCompleted ++ ")")
        ]

infoFooter : Html Msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text "Double-click to edit a todo" ] 
        ]