lkl.controller('shop', function($scope, connectServer, mobileapi, utils, common) {
	$scope.shopType = 'history';
	$scope.selectedSuperMarketParent = '';
	$scope.selectedVegetableMarketArea = '';
	$scope.isLoadSuccess = true;
	$scope.isOnLine = true;
	
	function showShopList() {
		$scope.shopData.loadChoiceHistory();
		$scope.shopData.findNearbyShop();
//		if($scope.shopData.shopNearbyArr.length > 0) {
//			$scope.shopType = 'nearby';
//		} else 
		if($scope.shopData.shopHistory.length > 0) {
			$scope.shopType = 'history';
		} else {
			$scope.shopType = $scope.shopData.typeSuper;
		}
	}
	
	$scope.searchShop = function(){
		common.pushPage('search');
	};
	$scope.reloadShop = function(){
		getShopList();
	};
	
	$scope.clickSuperMarketParent = function(data) {
		$scope.selectedSuperMarketParent = data.node_id;
	};
	
	$scope.clickVegetableMarketArea = function(data) {
		$scope.selectedVegetableMarketArea = data.area_id;
	};
	
	$scope.clickShop = function(shopData) {
//		common.popPage();
		$scope.shopData.choiceShop(shopData);
	};
	
	function getShopList() {
		var self = this;
		common.loading();
		$scope.shopData.getShopData(function(isSuccess) {
			$scope.isLoadSuccess = isSuccess;
			if(!isSuccess){
				$scope.isOnLine = PARAMS.isonline;
			}
			showShopList();
			if($scope.shopData.superMarketParentArr.length > 0) {
				$scope.selectedSuperMarketParent =  $scope.shopData.superMarketParentArr[0].node_id;
			}
			if($scope.shopData.vegetableMarketAreaArr.length > 0) {
				$scope.selectedVegetableMarketArea = $scope.shopData.vegetableMarketAreaArr[0].area_id;
			}
			common.closeLoading();
		});
	};
	
	getShopList();
});