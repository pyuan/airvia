package com.models
{
	import com.controllers.ApplicationController;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class Model
	{
		public var mapUrl:String = "";
		
		public var coordinates:ArrayCollection = new ArrayCollection();
		
		public var baseDate:Date;
		
		public var endDate:Date;
		
		public var startDate:Date = new Date();
		
		public var fromStationIndex:int = 0;
		
		public var toStationIndex:int = 0;
		
		public function Model()
		{
		}
		
		public static function getInstance():Model
		{
			return ApplicationController.SINGLETON.model;
		}

	}
}