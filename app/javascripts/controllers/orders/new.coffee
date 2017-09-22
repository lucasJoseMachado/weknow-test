app = angular.module('weknow-test')

app.controller 'OrderNewCtrl', ($scope, Order, $stateParams, $state) ->
  $scope.block_save_button = {status: false}

  if $stateParams.id
    Order.get(id: $stateParams.id).$promise.then (order) ->
      $scope.order = order
  else
    $scope.order = {itens: []}

  $scope.check_save_disabled = () ->
    !$scope.order.cliente

  $scope.add_product = () ->
    $scope.order.itens.push({produto: '', valor: 0})

  $scope.deleteItem = (index) ->
    item = $scope.order.itens[index]
    $scope.order.itens.splice(index, 1)

  $scope.save = () ->
    if $scope.block_save_button.status == true
      return
    $scope.block_save_button.status = true
    if $scope.order._id
      Order.update(id: $scope.order._id, order: $scope.order).$promise.then( () ->
        $state.go 'order_index'
      ).catch ->
        alert('erro ao atualizar pedido')
        $scope.block_save_button.status = false
    else
      Order.save($scope.order).$promise.then( () ->
        $state.go 'order_index'
      ).catch ->
        $scope.block_save_button.status = false
