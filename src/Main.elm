port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, p, text)
import Html.Attributes exposing (attribute, class, disabled)
import Html.Events exposing (onClick)
import Task
import Time


port visibilityChanged : (Bool -> msg) -> Sub msg


type alias Flags =
    { initiallyVisible : Bool
    , refreshIntervalMs : Float
    }


type alias Model =
    { isVisible : Bool
    , refreshIntervalMs : Float
    , refreshCount : Int
    , lastRefresh : Maybe Time.Posix
    }


type Msg
    = VisibilityChanged Bool
    | RefreshTick Time.Posix
    | ManualRefresh


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { isVisible = flags.initiallyVisible
      , refreshIntervalMs = max 1000 flags.refreshIntervalMs
      , refreshCount = 0
      , lastRefresh = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VisibilityChanged isVisible ->
            ( { model | isVisible = isVisible }, Cmd.none )

        RefreshTick now ->
            if model.isVisible then
                recordRefresh now model

            else
                -- Defensive guard for a tick queued during a visibility change.
                ( model, Cmd.none )

        ManualRefresh ->
            ( model, Task.perform RefreshTick Time.now )


recordRefresh : Time.Posix -> Model -> ( Model, Cmd Msg )
recordRefresh now model =
    ( { model
        | refreshCount = model.refreshCount + 1
        , lastRefresh = Just now
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ visibilityChanged VisibilityChanged
        , if model.isVisible then
            Time.every model.refreshIntervalMs RefreshTick

          else
            Sub.none
        ]


view : Model -> Html Msg
view model =
    div [ class "app-shell" ]
        [ h1 [] [ text "Visibility-aware polling" ]
        , p
            [ class (statusClass model.isVisible)
            , attribute "aria-live" "polite"
            ]
            [ text (statusText model.isVisible) ]
        , p []
            [ text
                ("Completed refreshes: "
                    ++ String.fromInt model.refreshCount
                )
            ]
        , p [] [ text (lastRefreshText model.lastRefresh) ]
        , button
            [ onClick ManualRefresh
            , disabled (not model.isVisible)
            ]
            [ text "Refresh now" ]
        ]


statusClass : Bool -> String
statusClass isVisible =
    if isVisible then
        "status status--active"

    else
        "status status--paused"


statusText : Bool -> String
statusText isVisible =
    if isVisible then
        "Active: periodic refresh is enabled"

    else
        "Paused: this page is hidden"


lastRefreshText : Maybe Time.Posix -> String
lastRefreshText maybeTime =
    case maybeTime of
        Nothing ->
            "No refresh has completed yet."

        Just time ->
            "Last refresh timestamp: "
                ++ String.fromInt (Time.posixToMillis time)
                ++ " ms since Unix epoch"
