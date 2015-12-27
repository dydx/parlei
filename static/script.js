(function () {
  'use strict'

  let stream = new EventSource('/events/last_five')
  let average = new EventSource('/events/average')

  average.addEventListener('message', function (event) {
    document.querySelector('.average').textContent = event.data
  })

  stream.addEventListener('message', function (event) {
    let data = JSON.parse( event.data );
    let elements = data.map(function (el) { return "<li>" + el + "</li>" }).join('\n')
    document.querySelector('.posts').innerHTML = `<ul> ${elements} </ul>`
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
