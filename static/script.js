(function () {
 'use strict'
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

  let stream = new EventSource('/events')

  stream.addEventListener('message', function (event) {
    console.log('Got a Message')
    console.log(event.data)
  })

  stream.addEventListener('open', function(e) {
    console.log('connection opened', e)
  }, false);

  stream.addEventListener('error', function(e) {
    console.log('Error', e)
  }, false);
})()
