$ ->
  # Set up masks for input fields
  $('#phone').mask('(999) 999-9999')
  $('#zip').mask('99999')

  # Size the form
  resize = ->
    $('#form-container').css 'height', $(window).height() - $('#form-container').offset().top - $('.footer').height() - 50
  $(window).on 'resize', =>
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

  submit = ->
    if !$('#signup-form').is(':invalid')
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
      $('#signup-form input:invalid').addClass 'invalid'

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

  # Validate inputs when they blur
  $('#signup-form input').on 'blur', ->
    if $(@).is(':invalid')
      $(@).addClass 'invalid'
    else
      $(@).removeClass 'invalid'

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

  # Require cell phone # if the text msg box is checked
  $('#canText').on 'change', =>
    if $('#canText').is(':checked')
      $('#phone').attr('required', 'required')
    else
      $('#phone').removeAttr 'required'
      $('#phone').removeClass 'invalid'

  # Handle form submission
  $('#signup-form').on 'submit', (event) =>
    event.preventDefault()
    submit()
  $('#signup-form input.submit').on 'click', (event) =>
    event.preventDefault()
    submit()

  # "Secret" click to send the queue
  $('.footer img').on 'click', =>
    sendSignups()