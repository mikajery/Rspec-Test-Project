describe "User", ->
  beforeEach ->
    @user = new TuringEmailApp.Models.User()

  it "has the right url", ->
    expect(@user.url).toEqual("/api/v1/users/current")

  it "is required the email true", ->
    expect( @user.validation.email.required ).toBeTruthy

  it "is required the pattern 'email'", ->
    expect( @user.validation.email.pattern ).toEqual "email"
