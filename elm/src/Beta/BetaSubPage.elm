port module BetaSubPage exposing (Model(..), Msg(..), init, urlUpdate, update, view, subscriptions)

import Json.Encode
import Html exposing (Html)
import Http
import NotFound
import String
import Task
import Autoscroll
import Concourse
import Concourse.Pipeline
import NoPipeline
import BetaRoutes
import QueryString
import BetaBuild
import BetaJob
import BetaPipeline
import BetaResource
import UpdateMsg exposing (UpdateMsg)


-- TODO: move ports somewhere else


port renderPipeline : ( Json.Encode.Value, Json.Encode.Value ) -> Cmd msg


port setTitle : String -> Cmd msg


type Model
    = WaitingModel BetaRoutes.ConcourseRoute
    | NoPipelineModel
    | NotFoundModel NotFound.Model
    | BetaBuildModel (Autoscroll.Model BetaBuild.Model)
    | BetaJobModel BetaJob.Model
    | BetaPipelineModel BetaPipeline.Model
    | BetaResourceModel BetaResource.Model


type Msg
    = PipelinesFetched (Result Http.Error (List Concourse.Pipeline))
    | DefaultPipelineFetched (Maybe Concourse.Pipeline)
    | NoPipelineMsg NoPipeline.Msg
    | BetaBuildMsg (Autoscroll.Msg BetaBuild.Msg)
    | BetaJobMsg BetaJob.Msg
    | BetaPipelineMsg BetaPipeline.Msg
    | BetaResourceMsg BetaResource.Msg
    | NewCSRFToken String


superDupleWrap : ( a -> b, c -> d ) -> ( a, Cmd c ) -> ( b, Cmd d )
superDupleWrap ( modelFunc, msgFunc ) ( model, msg ) =
    ( modelFunc model, Cmd.map msgFunc msg )


queryGroupsForRoute : BetaRoutes.ConcourseRoute -> List String
queryGroupsForRoute route =
    QueryString.all "groups" route.queries


init : String -> BetaRoutes.ConcourseRoute -> ( Model, Cmd Msg )
init turbulencePath route =
    case route.logical of
        BetaRoutes.BetaBuild teamName pipelineName jobName buildName ->
            superDupleWrap ( BetaBuildModel, BetaBuildMsg ) <|
                Autoscroll.init
                    BetaBuild.getScrollBehavior
                    << BetaBuild.init
                        { title = setTitle }
                        { csrfToken = "", hash = route.hash }
                <|
                    BetaBuild.JobBuildPage
                        { teamName = teamName
                        , pipelineName = pipelineName
                        , jobName = jobName
                        , buildName = buildName
                        }

        BetaRoutes.BetaJob teamName pipelineName jobName ->
            superDupleWrap ( BetaJobModel, BetaJobMsg ) <|
                BetaJob.init
                    { title = setTitle }
                    { jobName = jobName
                    , teamName = teamName
                    , pipelineName = pipelineName
                    , paging = route.page
                    , csrfToken = ""
                    }

        BetaRoutes.BetaOneOffBuild buildId ->
            superDupleWrap ( BetaBuildModel, BetaBuildMsg ) <|
                Autoscroll.init
                    BetaBuild.getScrollBehavior
                    << BetaBuild.init
                        { title = setTitle }
                        { csrfToken = "", hash = route.hash }
                <|
                    BetaBuild.BuildPage <|
                        Result.withDefault 0 (String.toInt buildId)

        BetaRoutes.BetaPipeline teamName pipelineName ->
            superDupleWrap ( BetaPipelineModel, BetaPipelineMsg ) <|
                BetaPipeline.init
                    { title = setTitle
                    }
                    { teamName = teamName
                    , pipelineName = pipelineName
                    , turbulenceImgSrc = turbulencePath
                    , route = route
                    }

        BetaRoutes.BetaResource teamName pipelineName resourceName ->
            superDupleWrap ( BetaResourceModel, BetaResourceMsg ) <|
                BetaResource.init
                    { title = setTitle }
                    { resourceName = resourceName
                    , teamName = teamName
                    , pipelineName = pipelineName
                    , paging = route.page
                    , csrfToken = ""
                    }

        BetaRoutes.BetaHome ->
            ( WaitingModel route
            , Cmd.batch
                [ fetchPipelines
                , setTitle ""
                ]
            )


handleNotFound : String -> ( a -> Model, c -> Msg ) -> ( a, Cmd c, Maybe UpdateMsg ) -> ( Model, Cmd Msg )
handleNotFound notFound ( mdlFunc, msgFunc ) ( mdl, msg, outMessage ) =
    case outMessage of
        Just UpdateMsg.NotFound ->
            ( NotFoundModel { notFoundImgSrc = notFound }, setTitle "Not Found " )

        Nothing ->
            superDupleWrap ( mdlFunc, msgFunc ) <| ( mdl, msg )


update : String -> String -> Concourse.CSRFToken -> Msg -> Model -> ( Model, Cmd Msg )
update turbulence notFound csrfToken msg mdl =
    case ( msg, mdl ) of
        ( NoPipelineMsg msg, model ) ->
            ( model, fetchPipelines )

        ( NewCSRFToken c, BetaBuildModel scrollModel ) ->
            let
                buildModel =
                    scrollModel.subModel

                ( newBuildModel, buildCmd ) =
                    BetaBuild.update (BetaBuild.NewCSRFToken c) buildModel
            in
                ( BetaBuildModel { scrollModel | subModel = newBuildModel }, buildCmd |> Cmd.map (\buildMsg -> BetaBuildMsg (Autoscroll.SubMsg buildMsg)) )

        ( NewCSRFToken c, BetaJobModel model ) ->
            ( BetaJobModel { model | csrfToken = c }, Cmd.none )

        ( NewCSRFToken c, BetaResourceModel model ) ->
            ( BetaResourceModel { model | csrfToken = c }, Cmd.none )

        ( BetaResourceMsg message, BetaResourceModel model ) ->
            handleNotFound notFound ( BetaResourceModel, BetaResourceMsg ) (BetaResource.updateWithMessage message { model | csrfToken = csrfToken })

        ( DefaultPipelineFetched pipeline, WaitingModel route ) ->
            case pipeline of
                Nothing ->
                    ( NoPipelineModel, setTitle "" )

                Just p ->
                    let
                        flags =
                            { teamName = p.teamName
                            , pipelineName = p.name
                            , turbulenceImgSrc = turbulence
                            , route = route
                            }
                    in
                        if String.startsWith "/beta" (BetaRoutes.toString route.logical) then
                            superDupleWrap ( BetaPipelineModel, BetaPipelineMsg ) <|
                                BetaPipeline.init { title = setTitle } flags
                        else
                            superDupleWrap
                                ( BetaPipelineModel, BetaPipelineMsg )
                            <|
                                BetaPipeline.init { title = setTitle } flags

        ( NewCSRFToken _, _ ) ->
            ( mdl, Cmd.none )

        ( BetaBuildMsg message, BetaBuildModel scrollModel ) ->
            let
                subModel =
                    scrollModel.subModel

                model =
                    { scrollModel | subModel = { subModel | csrfToken = csrfToken } }
            in
                handleNotFound notFound ( BetaBuildModel, BetaBuildMsg ) (Autoscroll.update BetaBuild.updateWithMessage message model)

        ( BetaJobMsg message, BetaJobModel model ) ->
            handleNotFound notFound ( BetaJobModel, BetaJobMsg ) (BetaJob.updateWithMessage message { model | csrfToken = csrfToken })

        ( BetaPipelineMsg message, BetaPipelineModel model ) ->
            superDupleWrap ( BetaPipelineModel, BetaPipelineMsg ) <| BetaPipeline.update message model

        unknown ->
            flip always (Debug.log ("impossible combination") unknown) <|
                ( mdl, Cmd.none )


urlUpdate : BetaRoutes.ConcourseRoute -> Model -> ( Model, Cmd Msg )
urlUpdate route model =
    case ( route.logical, model ) of
        ( BetaRoutes.BetaBuild teamName pipelineName jobName buildName, BetaBuildModel scrollModel ) ->
            let
                ( submodel, subcmd ) =
                    BetaBuild.changeToBuild
                        (BetaBuild.JobBuildPage
                            { teamName = teamName
                            , pipelineName = pipelineName
                            , jobName = jobName
                            , buildName = buildName
                            }
                        )
                        scrollModel.subModel
            in
                ( BetaBuildModel { scrollModel | subModel = submodel }
                , Cmd.map BetaBuildMsg (Cmd.map Autoscroll.SubMsg subcmd)
                )

        ( BetaRoutes.BetaJob teamName pipelineName jobName, BetaJobModel mdl ) ->
            superDupleWrap ( BetaJobModel, BetaJobMsg ) <|
                BetaJob.changeToJob
                    { teamName = teamName
                    , pipelineName = pipelineName
                    , jobName = jobName
                    , paging = route.page
                    , csrfToken = mdl.csrfToken
                    }
                    mdl

        ( BetaRoutes.BetaPipeline team pipeline, BetaPipelineModel mdl ) ->
            superDupleWrap ( BetaPipelineModel, BetaPipelineMsg ) <|
                BetaPipeline.changeToPipelineAndGroups
                    { teamName = team
                    , pipelineName = pipeline
                    , turbulenceImgSrc = mdl.turbulenceImgSrc
                    , route = route
                    }
                    mdl

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view mdl =
    case mdl of
        WaitingModel _ ->
            Html.div [] []

        NoPipelineModel ->
            Html.map NoPipelineMsg <| NoPipeline.view

        NotFoundModel model ->
            NotFound.view model

        BetaBuildModel model ->
            Html.map BetaBuildMsg <| Autoscroll.view BetaBuild.view model

        BetaJobModel model ->
            Html.map BetaJobMsg <| BetaJob.view model

        BetaPipelineModel model ->
            Html.map BetaPipelineMsg <| BetaPipeline.view model

        BetaResourceModel model ->
            Html.map BetaResourceMsg <| BetaResource.view model


subscriptions : Model -> Sub Msg
subscriptions mdl =
    case mdl of
        NoPipelineModel ->
            Sub.map NoPipelineMsg <| NoPipeline.subscriptions

        WaitingModel _ ->
            Sub.none

        NotFoundModel _ ->
            Sub.none

        BetaBuildModel model ->
            Sub.map BetaBuildMsg <| Autoscroll.subscriptions BetaBuild.subscriptions model

        BetaJobModel model ->
            Sub.map BetaJobMsg <| BetaJob.subscriptions model

        BetaPipelineModel model ->
            Sub.map BetaPipelineMsg <| BetaPipeline.subscriptions model

        BetaResourceModel model ->
            Sub.map BetaResourceMsg <| BetaResource.subscriptions model


fetchPipelines : Cmd Msg
fetchPipelines =
    Task.attempt PipelinesFetched Concourse.Pipeline.fetchPipelines
