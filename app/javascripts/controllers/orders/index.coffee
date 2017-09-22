app = angular.module('weknow-test')

app.controller 'OrderIndexCtrl', ($scope, Order) ->
  $scope.orders = []

  Order.query().$promise.then (orders) ->
    $scope.orders = orders

  $scope.delete = (index) ->
    product = $scope.orders[index]
    Order.delete(id: product._id).$promise.then () ->
      $scope.orders.splice(index, 1)