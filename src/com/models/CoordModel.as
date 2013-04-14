package com.models
{
	import com.utils.StringUtil;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class CoordModel
	{
		public var name:String = "";
		
		public var date:Date; //date used to calculate time
		
		public var pos:Point;
		
		public var time:Number; //ms it takes to get to location from base time
		
		public var pictures:ArrayCollection = new ArrayCollection();
		
		public function CoordModel(name:String, date:String, pos:String)
		{
			this.name = name;
			
			var dateArray:Array = date.split("/");
			this.date = StringUtil.stringToDate(date);
			
			var posArray:Array = pos.split("/");
			this.pos = new Point(posArray[0], posArray[1]);
			
			var model:Model = Model.getInstance();
			var base:Date = model.baseDate;
			var baseToUTC:Number = Date.UTC(base.fullYearUTC, base.monthUTC, base.dateUTC, base.hoursUTC, base.minutesUTC);
			var dateToUTC:Number = Date.UTC(this.date.fullYearUTC, this.date.monthUTC, this.date.dateUTC, this.date.hoursUTC, this.date.minutesUTC);
			this.time = dateToUTC - baseToUTC;
			
			trace("Setting point model: " + this.name);	
		}

	}
}