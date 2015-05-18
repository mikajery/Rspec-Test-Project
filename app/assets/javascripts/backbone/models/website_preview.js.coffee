class TuringEmailApp.Models.WebsitePreview extends Backbone.Model
  url: "/api/v1/website_previews/proxy?url="

  initialize: (options) ->
    @url += options.websiteURL

  websiteURLIs: (websiteURL) ->
    @url = "/api/v1/website_previews/proxy?url=" + websiteURL

  parse: (response, options) ->
    parsedResponse = []
    parsedResponse["url"] = response["url"]
    parsedResponse["html"] = response["html"]
    parsedResponse["title"] = response["html"]?.match(/<title>(.*?)<\/title>/)?[0]?.replace("<title>", "")?.replace("</title>", "")
    parsedResponse["snippet"] = response["html"]?.match(/<meta name="Description" content="(.*?)" \/>/)?[0]?.replace('<meta name="Description" content="', "")?.replace('" />', "")
    parsedResponse["imageUrl"] = response["html"]?.match(/<meta property="og:image" content="(.*?)" \/>/)?[0]?.replace('<meta property="og:image" content="', "")?.replace('" />', "")
    return parsedResponse
