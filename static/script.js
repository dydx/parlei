(function () {
  'use strict'

  let stream = new EventSource('/events')

  stream.addEventListener('message', function (event) {
    console.log("Message: ", event.data)
    document.querySelector('.posts').innerHTML = `${event.data}`
  })

  let form = document.querySelector('#post_form')
  form.addEventListener('submit', function (event) {
    event.preventDefault()

    // create a new Request object with the contents for the Form
    let request = new Request('/', {
      method: 'post',
      body: new FormData(form)
    })

    fetch(request).then(function (response) {
      console.log(response.status)
    }).then(function () {
      form.reset()
    })
  })

})()
