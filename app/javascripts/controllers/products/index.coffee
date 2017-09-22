app = angular.module('weknow-test')

app.controller 'ProductIndexCtrl', ($scope, Product) ->
  $scope.products = []

  Product.query().$promise.then (products) ->
    $scope.products = products

  $scope.delete = (index) ->
    product = $scope.products[index]
    Product.delete(id: product._id).$promise.then () ->
      $scope.products.splice(index, 1)