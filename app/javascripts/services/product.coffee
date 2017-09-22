angular.module('weknow-test')

.factory('Product', [
  '$resource', ($resource) ->
    $resource('/api/produtos/:id', {id: '@id'}, {
      update:
        method: 'PUT'
        url: '/api/produtos/:id'
    })
])
