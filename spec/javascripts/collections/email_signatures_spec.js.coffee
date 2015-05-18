describe "EmailSignaturesCollection", ->
  beforeEach ->
    @emailSignatures = new TuringEmailApp.Collections.EmailSignaturesCollection()

  it "uses the Email Signature model", ->
    expect(@emailSignatures.model).toEqual(TuringEmailApp.Models.EmailSignature)

  it "has the right URL", ->
    expect(@emailSignatures.url).toEqual("/api/v1/email_signatures")
