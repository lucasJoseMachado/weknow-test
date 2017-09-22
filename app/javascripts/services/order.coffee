angular.module('weknow-test')

.factory('Order', [
  '$resource', ($resource) ->
    $resource('/api/pedidos/:id', {id: '@id'}, {
      update:
        method: 'PUT'
        url: '/api/pedidos/:id'
    })
])
