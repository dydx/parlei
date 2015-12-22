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
     console.log(response)
   }).then(function () {
     form.reset()
   })
 })
})()
