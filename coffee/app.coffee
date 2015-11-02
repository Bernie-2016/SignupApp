$ ->
  # Set up masks for input fields
  $('#phone').mask('(999) 999-9999')
  $('#zip').mask('99999')

  # Size the form
  resize = ->
    $('#form-container').css 'height', $(window).height() - $('#form-container').offset().top - $('.footer').height() - 50
  $(window).on 'resize', ->
    resize()
  resize()

  # Set up Dexie DB
  db = new Dexie('SignupApp')
  db.version(1).stores
    signups: '++id, first_name, last_name, email, phone, zip, canText, isStored'
  db.open()

  # Method to add signup to IndexedDB
  addSignup = (signup) ->
    db.signups.add(signup)

  # Method to send signups to the API
  sendSignups = ->
    db.signups.where('isStored').equals(0).toArray().then( (unsent) ->
      return if unsent.length == 0
      $.ajax
        method: 'post'
        url: 'https://sanders-api.herokuapp.com/api/v1/signups'
        data: 
          signups: unsent
          secret: window.secret
        success: (response) ->
          for id in response.processed_ids
            db.signups.where('id').equals(parseInt(id)).delete()
    ).catch( (error) ->
      console.log error
    )

  # Method to validate the form
  validateForm = ->
    valid = true

    # Check each field.
    for field in ['first_name', 'last_name', 'phone', 'email', 'zip']
      fieldInput = $("##{field}")
      fieldInvalid = true unless typeof(validate.single(fieldInput.val(), presence: true)) is 'undefined'
      fieldInvalid = false if field is 'phone' && !$('#canText').is(':checked')
      fieldInvalid = true if field is 'email' && typeof(validate.single(fieldInput.val(), email: true)) isnt 'undefined'
      if fieldInvalid
        fieldInput.addClass 'invalid'
        valid = false
      else
        fieldInput.removeClass 'invalid'

    # Return overall result.
    valid

  submit = ->
    if validateForm()
      data = 
        first_name: $('#first_name').val()
        last_name: $('#last_name').val()
        email: $('#email').val()
        phone: $('#phone').val()
        zip: $('#zip').val()
        canText: $('#canText').is(':checked')
        isStored: 0

      addSignup(data)
      sendSignups()
      chrome.runtime.sendMessage(data)

      $('.submit').animate
        backgroundColor: '#4ACC66'
      , 500
      setTimeout ->
        $('.submit').val('Thanks!')
      , 250
      setTimeout ->
        $('.submit').animate
          backgroundColor: '#fd505e'
        , 500
      , 1500
      setTimeout ->
        $('.submit').val('Sign Me Up')
      , 1750
      setTimeout ->
        $('#signup-form')[0].reset()
        $('#name').focus()
      , 2000
    else
      $('.submit').animate
        backgroundColor: 'red'
      , 500
      setTimeout ->
        $('.submit').val('Missing Fields!')
      , 250
      setTimeout ->
        $('.submit').animate
          backgroundColor: '#fd505e'
        , 500
      , 1500
      setTimeout ->
        $('.submit').val('Sign Me Up')
      , 1750

  # Check email form
  $('#email').on 'blur', ->
    $(@).mailcheck
      suggested: (element, suggestion) ->
        $('small.email-suggestion').data('email-suggestion', suggestion.full)
        $('small.email-suggestion .suggestion').html("Did you mean #{suggestion.address}@<strong>#{suggestion.domain}</strong>?")
        $('small.email-suggestion').show()
      empty: (element) ->
        $('small.email-suggestion').hide()
  $('small.email-suggestion').on 'click', (event) ->
    return if $(event.target).is('.x')
    $('#email').val($(@).data('email-suggestion'))
    $('small.email-suggestion').hide()
  $('small.email-suggestion .x').on 'click', ->
    $('small.email-suggestion').hide()

  # Validate inputs when they blur
  $('#signup-form input').on 'blur', ->
    validateForm()

  # Handle form submission
  $('#signup-form').on 'submit', (event) ->
    event.preventDefault()
    submit()
  $('#signup-form input.submit').on 'click', (event) ->
    event.preventDefault()
    submit()

  # Resend the queue every 15 seconds in event of poor internet connection.
  window.setInterval ->
    sendSignups()
  , 15000