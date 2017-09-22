app = angular.module('weknow-test')

app.controller 'ProductNewCtrl', ($scope, Product, $stateParams, $state) ->
  $scope.block_save_button = {status: false}

  if $stateParams.id
    Product.get(id: $stateParams.id).$promise.then (product) ->
      $scope.product = product

  $scope.check_save_disabled = () ->
    !$scope.product || !$scope.product.descricao

  $scope.save = () ->
    if $scope.block_save_button.status == true
      return
    $scope.block_save_button.status = true
    if $scope.product._id
      Product.update(id: $scope.product._id, produto: $scope.product).$promise.then( () ->
        $state.go 'product_index'
      ).catch ->
        alert('erro ao atualizar produto')
        $scope.block_save_button.status = false
    else
      Product.save($scope.product).$promise.then( () ->
        $state.go 'product_index'
      ).catch ->
        $scope.block_save_button.status = false
