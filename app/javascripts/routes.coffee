app = angular.module('weknow-test')

app.config(($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise("/produtos")

  $stateProvider
    .state 'main',
      controller: 'MainCtrl'
      url: '/'
      templateUrl: '/templates/layouts/main.html'

    .state 'product_index',
      controller: 'ProductIndexCtrl'
      url: '/produtos'
      templateUrl: '/templates/products/index.html'
    .state 'product_new',
      controller: 'ProductNewCtrl'
      url: '/produtos/novo'
      templateUrl: '/templates/products/new.html'
    .state 'product_edit',
      controller: 'ProductNewCtrl'
      url: '/produtos/:id'
      templateUrl: '/templates/products/new.html'

    .state 'order_index',
      controller: 'OrderIndexCtrl'
      url: '/pedidos'
      templateUrl: '/templates/orders/index.html'
    .state 'order_new',
      controller: 'OrderNewCtrl'
      url: '/pedidos/novo'
      templateUrl: '/templates/orders/new.html'
    .state 'order_edit',
      controller: 'OrderNewCtrl'
      url: '/pedidos/:id'
      templateUrl: '/templates/orders/new.html'
)
