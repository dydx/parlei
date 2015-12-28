(function () {
  'use strict'

  // I've got room for 1-2 more of these. Might be about time
  // to consider dumping the whole update stream into one JSON
  let total = new EventSource('/events/total')
  let average = new EventSource('/events/average')
  let longest = new EventSource('/events/longest')
  let last_five = new EventSource('/events/last_five')

  total.addEventListener('message', function (event) {
    document.querySelector('.total').textContent = event.data
  })

  average.addEventListener('message', function (event) {
    document.querySelector('.average').textContent = event.data
  })

  longest.addEventListener('message', function (event) {
    document.querySelector('.longest').textContent = event.data
  })

  last_five.addEventListener('message', function (event) {
    document.querySelector('.posts').textContent = event.data
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
