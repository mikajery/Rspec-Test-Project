class TuringEmailApp.Views.TourView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/tour/tour"]

  events: -> _.extend {}, super(),
    "click .tm_tour-skip": "hide"
    "click .tm_tour-prev": "prev"
    "click .tm_tour-next": "next"
    "click .tm_tour-chapter": "goto"

  render: ->
    @$el.html(@template())

    @show()
    @hidePrev()

    @

  #################
  ### Show/Hide ###
  #################

  show: ->
    @$(".tour-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).on("shown.bs.modal", ->
      $(".tm_tour", this).addClass("animate")
    ).show()

  hide: ->
    @$(".tour-modal").modal "hide"

  showNext: ->
    @$(".tm_tour-next").show()

  hideNext: ->
    @$(".tm_tour-next").hide()

  showPrev: ->
    @$(".tm_tour-prev").show()

  hidePrev: ->
    @$(".tm_tour-prev").hide()

  showSlide: (index) ->
    $slides = @$(".tm_tour-slide")
    slidesCount = $slides.length - 1
    index = Math.max(0, Math.min(slidesCount, index))

    @$(".tm_tour-chapters").toggleClass("visible", index >= 2)
      .children().removeClass("active").eq(index - 2).addClass("active")

    $slides.removeClass("active").eq(index).addClass("active")

    if index == 0 then @hidePrev() else @showPrev()
    if index == slidesCount
      @hideNext()
      @$(".skip-tour-text").text("End Tour")
    else
      @showNext()
      @$(".skip-tour-text").text("Skip Tour")

  #################
  ### Next/Prev ###
  #################

  #TODO parametrize into more concise method.

  goto: (e) ->
    @showSlide $(e.currentTarget).index() + 2

  next: ->
    @showSlide @$(".tm_tour-slide.active").index() + 1

  prev: ->
    @showSlide @$(".tm_tour-slide.active").index() - 1
