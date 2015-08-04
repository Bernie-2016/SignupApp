$ ->
  # Set up masks for input fields
  $('#phone').mask('(999) 999-9999')
  $('#zip').mask('99999')

  # Size the form
  $('#form-container').css 'height', $(window).height() - $('#form-container').offset().top - $('.footer').height() - 50

  # Set up Dexie DB
  db = new Dexie('SignupApp')
  db.version(1).stores
    signups: '++id, name, email, phone, zip, canText, isStored'
  db.open()

  # Method to send signups to the API
  sendSignups = ->
    db.signups.where('isStored').equals(0).toArray().then( (unsent) ->
      $.ajax
        method: 'post'
        # url: 'https://sanders-api.herokuapp.com/api/v1/signups'
        url: 'http://localhost:3000/api/v1/signups'
        data: 
          signups: unsent
          secret: window.secret
        success: (response) ->
          for id in response.processed_ids
            db.signups.where('id').equals(parseInt(id)).delete()
    ).catch( (error) ->
      console.log error
    )

  # Validate inputs when they blur
  $('#signup-form input').on 'blur', ->
    if $(@).is(':invalid')
      $(@).addClass 'invalid'
    else
      $(@).removeClass 'invalid'

  # Handle form submission
  $('#signup-form').on 'submit', (event) =>
    event.preventDefault()
    if !$('#signup-form').is(':invalid')
      db.signups.add
        name: $('#name').val()
        email: $('#email').val()
        phone: $('#phone').val()
        zip: $('#zip').val()
        canText: $('#canText').is(':checked')
        isStored: 0
      sendSignups()

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