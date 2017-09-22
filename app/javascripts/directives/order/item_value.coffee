angular.module('weknow-test')

.directive 'itemValue', ($rootScope) ->
  {
    restrict: 'E'
    templateUrl: "/templates/orders/item_value.html"
    scope: 
      ngModel: '='
  }
