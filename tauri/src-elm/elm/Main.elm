port module Main exposing (main)

import Accessibility.Aria as Aria
import Browser
import FontAwesome as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import Html exposing (Html, a, button, div, h1, img, main_, p, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)



-- MESSAGES


type Msg
    = ViewModelUpdated ViewModel
    | CounterAppIncrement
    | CounterAppDecrement
    | CounterAppReset



-- MODEL


type alias Model =
    { counter : CounterViewModel
    }


type alias CounterViewModel =
    { count : Int
    }


type alias ViewModel =
    { counter : CounterViewModel
    }



-- CONSTANTS


type alias Name =
    String


type alias Logo =
    String


type alias Url =
    String


type alias TechStackData =
    { name : Name
    , url : Url
    , logo : Logo
    }


techStack : List TechStackData
techStack =
    [ { name = "Elm"
      , url = "https://elm-lang.org"
      , logo = "/assets/stack/elm.svg"
      }
    , { name = "TailwindCSS"
      , url = "https://tailwindcss.com"
      , logo = "/assets/stack/tailwind.svg"
      }
    , { name = "daisyUI"
      , url = "https://daisyui.com"
      , logo = "/assets/stack/daisyui.svg"
      }
    , { name = "Vite,JS"
      , url = "https://vite.dev"
      , logo = "/assets/stack/vite.svg"
      }
    , { name = "Tauri"
      , url = "https://tauri.app"
      , logo = "/assets/stack/tauri.svg"
      }
    , { name = "Crux"
      , url = "https://redbadger.github.io/crux/"
      , logo = "/assets/stack/crux.svg"
      }
    ]



-- INIT


init : () -> ( Model, Cmd Msg )
init () =
    ( { counter = { count = 0 }
      }
    , Cmd.none
    )



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- VIEW


view : Model -> Html Msg
view model =
    main_
        [ Aria.label "main content"
        , Attr.class "flex flex-col justify-center items-center w-full h-full font-sans text-center text-base-content bg-base-200"
        ]
        [ Icon.css
        , helloTauri model
        ]


helloTauri : Model -> Html Msg
helloTauri model =
    div
        [ Attr.class "hero min-h-screen"
        ]
        [ div
            [ Attr.class "hero-content min-h-fit"
            ]
            [ div
                [ Attr.class "max-w-md"
                ]
                [ title
                , counterApp model.counter.count
                , description
                , madeWith
                ]
            ]
        ]


title : Html Msg
title =
    h1
        [ Aria.label "Elm loves Tauri main title"
        , Attr.class "font-bold text-3xl flex gap-2 justify-center mb-4"
        ]
        [ text "Elm "
        , div [ Attr.class "text-red-500" ] [ Icon.view Icon.heart ]
        , text " Tauri"
        , div [ Attr.class "text-red-500" ] [ Icon.view Icon.heart ]
        , text " Crux"
        ]


counterApp : Int -> Html Msg
counterApp count =
    div [ Attr.class "m-auto" ]
        [ display count
        , buttons
        ]


display : Int -> Html Msg
display count =
    div
        [ Attr.class "text-2xl font-bold mb-2"
        ]
        [ text <| "The count is: " ++ String.fromInt count ]


buttons : Html Msg
buttons =
    let
        btns =
            [ ( CounterAppDecrement, "Decrement", Icon.minus )
            , ( CounterAppReset, "Reset", Icon.arrowRotateLeft )
            , ( CounterAppIncrement, "Increment", Icon.plus )
            ]
    in
    div
        [ Attr.class "flex gap-4 justify-center flex-wrap"
        ]
    <|
        List.map (\( message, label, icon ) -> btnComponent message label icon) btns


btnComponent : Msg -> String -> Icon.Icon hasId -> Html Msg
btnComponent message label icon =
    button
        [ Attr.class "btn btn-sm btn-outline"
        , onClick message
        , Aria.label <| label ++ " counter"
        ]
        [ Icon.view icon
        ]


description : Html Msg
description =
    p [ Attr.class "text-center text-sm text-base-content/70 mt-4" ]
        [ text "Click on a logo to learn more about each framework" ]


madeWith : Html Msg
madeWith =
    div
        [ Aria.label "Logos with links to the respective tech websites"
        , Attr.class "flex flex-col items-center gap-4 mt-2"
        ]
        [ div
            [ Attr.class "flex flex-wrap gap-4 justify-center"
            ]
            (List.map (\logoData -> logoLinkComponent logoData) techStack)
        ]


logoLinkComponent : TechStackData -> Html Msg
logoLinkComponent logoData =
    a
        [ Aria.label <| logoData.name ++ " logo with a link to " ++ logoData.name ++ " website"
        , Attr.href logoData.url
        , Attr.target "_blank"
        , Attr.rel "noopener noreferrer"
        , Attr.title <| "Learn more about " ++ logoData.name
        ]
        [ img
            [ Aria.label <| logoData.name ++ " logo"
            , Attr.src logoData.logo
            , Attr.class "w-8 h-8"
            , Attr.class "object-contain hover:scale-110 transition-transform"
            , Attr.alt <| logoData.name ++ " logo"
            ]
            []
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CounterAppIncrement ->
            ( model
            , sendACommandToCrux "increment"
            )

        CounterAppDecrement ->
            ( model
            , sendACommandToCrux "decrement"
            )

        CounterAppReset ->
            ( model
            , sendACommandToCrux "reset"
            )

        ViewModelUpdated viewModel ->
            ( { model
                | counter = viewModel.counter
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    listenForViewModel ViewModelUpdated



-- PORTS


port sendACommandToCrux : String -> Cmd msg


port listenForViewModel : (ViewModel -> msg) -> Sub msg
