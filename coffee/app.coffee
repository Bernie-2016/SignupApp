$ ->
  # Set up masks for input fields
  $('#phone').mask('(999) 999-9999')
  $('#zip').mask('99999')

  # Set up Dexie DB
  db = new Dexie('SignupApp')
  db.version(1).stores
    signups: '++id, name, email, phone, zip, canText, isStored'
  db.open()

  # Method to send signups to the API
  sendSignups = ->
    db.signups.where('isStored').equals(0).toArray().then( (unsent) ->
      console.log 'will send'
      console.log unsent
    ).catch( (error) ->
      console.log error
    )

  # Validate inputs when they blur
  $('#signup-form input').on 'blur', ->
    if $(@).valid()
      $(@).removeClass 'invalid'
    else
      $(@).addClass 'invalid'

  # Handle form submission
  $('#signup-form').on 'submit', (event) =>
    event.preventDefault()
    if $('#signup-form').validate().valid()
      db.signups.add
        name: $('#name').val()
        email: $('#email').val()
        phone: $('#phone').val()
        zip: $('#zip').val()
        canText: $('#canText').is(':checked')
        isStored: 0
      sendSignups()
      $('#signup-form')[0].reset()
      $('#name').focus()
    else
      alert 'not valid'